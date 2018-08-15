//  Copyright (c) 2018-present amlovey
//  
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;

namespace uCodeEditor
{
    /// <summary>
    /// Actions when files changed
    /// </summary>
    public class FileWatcher : AssetPostprocessor
    {
        public static HashSet<string> ALLOWED_FILES_CACHE = new HashSet<string>();

        private delegate void HandleAction(string path, string type, bool addOrRemove);

        public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
        {
            if (MainWindow.CommunicateServices == null)
            {
                return;
            }

            bool hasCSFileChanged = false;

            HandleAction action = (string path, string type, bool addOrRemove) =>
            {
                FileChangedWithAllowedCheck(path, type);
                if (!hasCSFileChanged)
                {
                    hasCSFileChanged = Utility.IsCSharpScript(path);
                }

                if (addOrRemove)
                {
                    ALLOWED_FILES_CACHE.Add(Path.GetFullPath(path));
                }
                else
                {
                    ALLOWED_FILES_CACHE.Remove(Path.GetFullPath(path));
                }
            };

            foreach (string path in deletedAssets)
            {
                action(path, "delete", false);
            }

            foreach (string path in movedFromAssetPaths)
            {
                action(path, "delete", false);
            }

            foreach (string path in movedAssets)
            {
                action(path, "add", true);
            }

            foreach (string path in importedAssets)
            {
                action(path, "change", true);
            }

            if (hasCSFileChanged)
            {
                ClearSolution();
                SyncSolution();
            }

            File.WriteAllLines(PathManager.GetGoToFileCachePath(), ALLOWED_FILES_CACHE.ToArray());
        }

        public static void RefreshAllowedFilesCache()
        {
            var files = Utility.GetAllAllowedFiles(OnLoad.WORKING_DIRECTORY);
            ALLOWED_FILES_CACHE.Clear();

            foreach (var item in files)
            {
                ALLOWED_FILES_CACHE.Add(item);
            }

            File.WriteAllLines(PathManager.GetGoToFileCachePath(), files.ToArray());
        }

        private static void FileChangedWithAllowedCheck(string path, string changeType)
        {
            if (string.IsNullOrEmpty(path)
                || string.IsNullOrEmpty(changeType)
                || MainWindow.CommunicateServices == null)
            {
                return;
            }

            if (Utility.IsFileAllowed(path))
            {
                MainWindow.CommunicateServices.FileChanged(path, changeType);
            }
        }

        public static void SyncSolution()
        {
            try
            {
                System.Type T = System.Type.GetType("UnityEditor.SyncVS,UnityEditor");
                System.Reflection.MethodInfo SyncSolution = T.GetMethod("SyncSolution", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
                SyncSolution.Invoke(null, null);

                var projectFolder = Path.Combine(Application.dataPath, "..");
                var projectFiles = Directory.GetFiles(projectFolder, "*.csproj");
                foreach (var item in projectFiles)
                {
                    if (MainWindow.CommunicateServices != null)
                    {
                        MainWindow.CommunicateServices.FileChanged(item, "change");
                    }
                }
            }
            catch (System.Exception e)
            {
                Debug.LogWarning(e);
            }
        }

        public static void ClearSolution()
        {
            var projectFolder = Path.Combine(Application.dataPath, "..");
            var solutionFiles = Directory.GetFiles(projectFolder, "*.sln");
            var projectFiles = Directory.GetFiles(projectFolder, "*.csproj");
            var unityProjectFiles = Directory.GetFiles(projectFolder, "*.unityproj");

            foreach (string solutionFile in solutionFiles)
            {
                File.Delete(solutionFile);
            }

            foreach (string projectFile in projectFiles)
            {
                File.Delete(projectFile);
            }

            foreach (string unityProjectFile in unityProjectFiles)
            {
                File.Delete(unityProjectFile);
            }
        }
    }
}