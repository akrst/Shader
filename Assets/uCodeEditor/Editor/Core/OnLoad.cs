//  Copyright (c) 2018-present amlovey
//  
using UnityEditor;
using UnityEngine;
using System.Reflection;
using System.Diagnostics;
using System.IO;
using System.Net;
using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEditor.Callbacks;
using System.Text.RegularExpressions;

namespace uCodeEditor
{
    [InitializeOnLoad]
    public class OnLoad
    {
        public static string SolutionPath;
        public static string Id;

        // Host that connect to Omnisharp. Please don't change the value.
        public static string HOST = "http://127.0.0.1:8188/";

        public static int PORT = 8188;
        public static string WORKING_DIRECTORY;
        private static string MONO_PATH;
        private static string STDIO_BRIDGE_PATH;
        private static Thread STDIO_THREAD;
        private static int PROCESS_ID;
        private static string PATH_EXTRA = "/Library/Frameworks/Mono.framework/Versions/Current/Commands/:/usr/local/bin/";

        static OnLoad()
        {
            SetDefaultScriptEditor();
            EditorUtility.ClearProgressBar();

            EditorCoroutine.StartCoroutine(SyncSolution());

            if (!OmniSharpManager.CheckInstallationExists())
            {
                OmniSharpManager.InstallOmnisharp();
            }

            MONO_PATH = MonoHelper.GetMonoLocation();
            STDIO_BRIDGE_PATH = GetStdioBridgePath();
            WORKING_DIRECTORY = Application.dataPath;
            PROCESS_ID = Process.GetCurrentProcess().Id;

            STDIO_THREAD = new Thread(new ThreadStart(LanuchOmniSharp));
            STDIO_THREAD.Start();

#if UNITY_2017_1_OR_NEWER
            EditorApplication.playModeStateChanged += e => { PlayModeStateChanged(); };
#else
            EditorApplication.playmodeStateChanged += PlayModeStateChanged;
#endif
            EditorApplication.update += FileSearch.Update;
        }

        private static void SetDefaultScriptEditor()
        {
            string key = "kScriptsDefaultApp";

            // Backup current value
            // var currentApp = EditorPrefs.GetString(key);
            EditorPrefs.SetString(key, "MonoDevelop (built-in)");

            try
            {
                // Clear and regnerated solution files
                FileWatcher.ClearSolution();
                FileWatcher.SyncSolution();
            }
            catch (Exception e)
            {
                UnityEngine.Debug.Log(e);
            }
            finally
            {
                // Restore Key
                // TODO: do we need to restore Key here?
                // EditorPrefs.SetString(key, currentApp);
            }
        }

        private static IEnumerator SyncSolution()
        {
            // we don't want to loop forever here
            int count = 0;
            while (string.IsNullOrEmpty(SolutionPath) || count > 100)
            {
                yield return new WaitForSeconds(1);
                count++;
                FindSolutionPath();
            }
            yield return null;
        }

        private static void PlayModeStateChanged()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                if (MainWindow.CommunicateServices != null)
                {
                    MainWindow.CommunicateServices.SaveAll();
                }

                AssetDatabase.Refresh();
            }
        }

        ~OnLoad()
        {
            if (STDIO_THREAD != null)
            {
                STDIO_THREAD.Abort();
            }
        }

        private static void LanuchOmniSharp()
        {
            FileWatcher.RefreshAllowedFilesCache();

            if (!IsStdioBridgeServerAlive())
            {
                StartStdioBridgeServer();

                // waiting for solution alive
                while (!IsStdioBridgeServerAlive())
                {
                    Thread.Sleep(1000);
                }
            }

            // Waiting for solution path
            while (string.IsNullOrEmpty(SolutionPath))
            {
                Thread.Sleep(1000);
            }

            Utility.Log("id=" + Utility.MD5(SolutionPath).ToLower());

            if (!string.IsNullOrEmpty(SolutionPath))
            {
                var existsProcess = GET(CreateLaunchProcessUrl());
                // waiting for process up
                while (existsProcess != "exists")
                {
                    Thread.Sleep(1000);
                    existsProcess = GET(CreateLaunchProcessUrl());
                    Utility.Log(existsProcess);
                }

                if (existsProcess == "exists")
                {
                    Utility.LogWithName("Connected to Omnisharp Server");
                }
            }
        }

        private static bool IsStdioBridgeServerAlive()
        {
            string url = "http://127.0.0.1:8188/?action=checkalive";
            string ret = GET(url);
            return ret == "200";
        }

        private static void StartStdioBridgeServer()
        {
            Utility.LogWithName("Starting StdioBridge Server");
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = MONO_PATH;
            startInfo.Arguments = string.Format("\"{0}\" -port {1} -omnisharp \"{2}\" -platform {3}", STDIO_BRIDGE_PATH, PORT, GetOmnisharpPath(), GetCurrentPlatform());
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.RedirectStandardError = true;
            startInfo.RedirectStandardOutput = true;
            startInfo.WorkingDirectory = WORKING_DIRECTORY;

            // need to set mono path to PATH enviroment variable, otherwise application will fails
            startInfo.EnvironmentVariables["PATH"] = string.Format("{0}:{1}", Environment.GetEnvironmentVariable("PATH"), PATH_EXTRA);

            Process p = new Process();
            p.StartInfo = startInfo;

            if (p.Start())
            {
                Utility.LogWithName("Started StdioBridge Server");
            }
        }

        private static string GetCurrentPlatform()
        {
            return Application.platform == RuntimePlatform.OSXEditor ? "mac" : "win";
        }

        private static string GetStdioBridgePath()
        {
            var installedPath = Utility.PathCombine(PathManager.GetUCEFolder(), "StdioBridge.exe");
            var tempPath = Utility.PathCombine(PathManager.GetUCEFolder(), "sb.db");
            var srcPath = Path.Combine(Application.dataPath, "uCodeEditor/Editor/Data/sb.db");

            if (!File.Exists(tempPath))
            {
                FileCopyWithErrorLess(srcPath, tempPath);
                Utility.Unpack(tempPath, installedPath);
                return installedPath;
            }

            // compare if it's lastest one, if not copy one
            var md5_1 = Utility.GetFileMD5(srcPath);
            var md5_2 = Utility.GetFileMD5(tempPath);

            if (md5_1 != md5_2)
            {
                Utility.LogWithName("Upgrading stdio bridge...");
                FileCopyWithErrorLess(srcPath, installedPath);
                Utility.Unpack(tempPath, installedPath);
            }

            return installedPath;
        }

        private static void FileCopyWithErrorLess(string src, string dst)
        {
            try
            {
                File.Copy(src, dst, true);
            }
            catch
            {

            }
        }

        private static string GetOmnisharpPath()
        {
            return OmniSharpManager.GetInstalledOmnisharpPath();
        }

        private static string CreateLaunchProcessUrl()
        {
            return string.Format("{0}?action=create&solution={1}&hostid={2}", HOST, Uri.EscapeDataString(SolutionPath), PROCESS_ID);
        }

        private static string GET(string url)
        {
            try
            {
                Utility.Log("Get " + url);
                var requeset = WebRequest.Create(url);
                var response = requeset.GetResponse();
                var reponseStream = response.GetResponseStream();
                using (StreamReader reader = new StreamReader(reponseStream))
                {
                    return reader.ReadToEnd();
                }
            }
            catch (Exception e)
            {
                Utility.Log(e);
            }

            return string.Empty;
        }

        private static void FindSolutionPath()
        {
            var files = Directory.GetFiles(Path.Combine(Application.dataPath, ".."), "*.sln");
            foreach (var file in files)
            {
                SolutionPath = Path.GetFullPath(file);
                Id = Utility.MD5(SolutionPath).ToLower();
                return;
            }
        }

        [OnOpenAssetAttribute(0)]
        public static bool OpenInUEByDoubleClick(int instanceID, int line)
        {
            var asset = EditorUtility.InstanceIDToObject(instanceID);
            var path = AssetDatabase.GetAssetPath(asset);

            Utility.Log(string.Format("Open {0} with line {1}", path, line));

            // If double click on Console Window
            var stackTrace = GetSelectedStackTrace();
            if (!string.IsNullOrEmpty(stackTrace))
            {
                if (line >= 0)
                {
                    if (!string.IsNullOrEmpty(path))
                    {
                        if (MainWindow.Instance != null)
                        {
                            MainWindow.LoadWindow();
                            MainWindow.CommunicateServices.UEOpenFile(path, line);
                        }
                        else
                        {
                            var filePath = Utility.PathNormalized(Path.GetFullPath(path));
                            PlayerPrefs.SetString(Constants.CURRENT_FILE_KEY, string.Format("{0}:{1}", filePath, line));
                            MainWindow.LoadWindow();
                        }

                        return true;
                    }
                }

                return false;
            }

            Utility.Log(string.Format("stack tracke = {0}", !string.IsNullOrEmpty(stackTrace)));

            // If not in Console Window
            // Check if it's a folder
            bool isDirectory = Utility.IsDirectory(path);
            if (isDirectory)
            {
                return true;
            }

            // If it's a file, check if it's valid file type
            if (Utility.IsFileAllowed(path))
            {
                if (MainWindow.Instance == null)
                {
                    var filePath = Utility.PathNormalized(Path.GetFullPath(path));
                    if (line > 0)
                    {
                        PlayerPrefs.SetString(Constants.CURRENT_FILE_KEY, string.Format("{0}:{1}", filePath, line));
                    }
                    else
                    {
                        PlayerPrefs.SetString(Constants.CURRENT_FILE_KEY, filePath);
                    }
                    
                    MainWindow.LoadWindow();
                }
                else
                {
                    MainWindow.LoadWindow();
                    MainWindow.CommunicateServices.UEOpenFile(path, line);
                }
            
                return true;
            }

            return false;
        }

        private static string GetSelectedStackTrace()
        {
            var type = typeof(EditorWindow).Assembly.GetType("UnityEditor.ConsoleWindow");
            var fieldInfo = type.GetField("ms_ConsoleWindow", BindingFlags.Static | BindingFlags.NonPublic);
            var console = fieldInfo.GetValue(null);

            if (null != console)
            {
                if ((object)EditorWindow.focusedWindow == console)
                {
                    fieldInfo = type.GetField("m_ActiveText", BindingFlags.Instance | BindingFlags.NonPublic);
                    string activeText = fieldInfo.GetValue(console).ToString();
                    return activeText;
                }
            }

            return "";
        }
    }
}