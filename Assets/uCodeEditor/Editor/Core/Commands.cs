//  Copyright (c) 2018-present amlovey
// 
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Diagnostics;
using System.IO;
using System.Text;
using System;

namespace uCodeEditor
{
    #region Core Commands

#if UNITY_EDITOR_WIN
	[UCommand("uce.toggle.maximize.editor", "Toggle uCodeEditor Maximize", KeyCode.CtrlCmd | KeyCode.Alt | KeyCode.KEY_X)]
#else
    [UCommand("uce.toggle.maximize.editor", "Toggle uCodeEditor Maximize", KeyCode.Shift | KeyCode.Space)]
#endif
    public class ToggleEditorMaximize : UDynmaicCommand
    {
        public override void Run()
        {
            if (MainWindow.Instance != null)
            {
                MainWindow.Instance.maximized = !MainWindow.Instance.maximized;
            }
        }
    }

    [UCommand("uce.online.documents", "Help: Online Documents")]
    public class OnlineDocuments : UDynmaicCommand
    {
        public override void Run()
        {
            EditorApplication.ExecuteMenuItem("Tools/uCodeEditor/Online Documentation");
        }
    }

#if UNITY_EDITOR_WIN
	[UCommand("uce.open.in.shell", "Project: Open In Command Line")]
#else
    [UCommand("uce.open.in.shell", "Project: Open In Terminal")]
#endif
    public class OpenProjectInShell : UDynmaicCommand
    {
        public override void Run()
        {
            var path = Utility.PathCombine(Application.dataPath, "..");

#if UNITY_EDITOR_WIN
			Process.Start("cmd", string.Format("-k {0}", path));
#else
            Process.Start("open", string.Format("-b com.apple.Terminal {0}", path));
#endif
        }
    }

    #endregion

    [UCommand("uce.export.settings", "Export Settings...")]
    public class ExportSettings : UDynmaicCommand
    {
        public override void Run()
        {
            var savePath = EditorUtility.SaveFilePanel(
                "Export Settings",
                Utility.PathCombine(Application.dataPath, ".."),
                "setting",
                Constants.SETTING_FILE_EXT);

            if (string.IsNullOrEmpty(savePath))
            {
                return;
            }

            // editor config
            var editorConfig = "{}";
            var editorConfigPath = PathManager.GetEditorConfigPath();
            StringBuilder sb = new StringBuilder();
            sb.Append("{");
            if (File.Exists(editorConfigPath))
            {
                editorConfig = File.ReadAllText(editorConfigPath);
                sb.Append(string.Format("\"editor\":{0},", editorConfig));
            }

            // key mapping
            var keymapping = "{}";
            var keymappingPath = PathManager.GetKeyMappingConfigPath();
            if (File.Exists(keymappingPath))
            {
                keymapping = File.ReadAllText(keymappingPath);
                sb.Append(string.Format("\"keymap\":{0}", keymapping));
            }

            sb.Append("}");

            File.WriteAllText(savePath, sb.ToString());
        }
    }

    [UCommand("uce.quick.open.scenes", "Unity Editor: Go To Scene...", KeyCode.CtrlCmd | KeyCode.US_QUOTE)]
    public class QuickOpenScenes : UQuickOpenCommand
    {
        public override void RunEntry(string id)
        {
            var guids = AssetDatabase.FindAssets("t:Scene");
            foreach (var gid in guids)
            {
                if (gid.Equals(id, StringComparison.OrdinalIgnoreCase))
                {
                    var path = AssetDatabase.GUIDToAssetPath(gid);
#if UNITY_5_3_OR_NEWER
                    if (UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene().isDirty)
                    {
                        UnityEditor.SceneManagement.EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo();
                    }

                    var openMode = UnityEditor.SceneManagement.OpenSceneMode.Single;
                    UnityEditor.SceneManagement.EditorSceneManager.OpenScene(path, openMode);
#else
                    if (EditorApplication.isSceneDirty)
                    {
                        EditorApplication.SaveCurrentSceneIfUserWantsTo();
                    }
                    
                    EditorApplication.OpenScene(path);
#endif
                    break;
                }
            }
        }

        public override IEnumerable<QuickOpenEntryMeta> GetQuickOpenEntries()
        {
            var guids = AssetDatabase.FindAssets("t:Scene");
            List<QuickOpenEntryMeta> data = new List<QuickOpenEntryMeta>();
            foreach (var id in guids)
            {
                QuickOpenEntryMeta meta = new QuickOpenEntryMeta();
                meta.id = id;

                var scenePath = AssetDatabase.GUIDToAssetPath(id);
                meta.label = Path.GetFileNameWithoutExtension(scenePath);
                meta.description = Path.GetDirectoryName(scenePath);
                meta.icon = "scene";

                data.Add(meta);
            }

            return data;
        }
    }

    [UCommand("uce.reveal.special.folder", "Unity Editor: Reveal Special Folder...")]
    public class RevealSpecialFolder : UQuickOpenCommand
    {
        private static string[] SPECIAL_FOLDERS = new string[] {
            "Application.persistentDataPath", // id = 0
            "Application.dataPath", //id = 1
            "Application.streamingAssetsPath", // id = 2
            "Application.temporaryCachePath", // id = 3 
            "Asset Store Packages Folder", // id = 4
            "Editor Application Path", // id = 5
            "Editor Log Folder", // id = 6
#if UNITY_2017_1_OR_NEWER
            "Packages Folder", // id = 7
#endif
        };

        public override void RunEntry(string id)
        {
            switch (id)
            {
                case "0":
                    Utility.Reveal(Application.persistentDataPath);
                    break;
                case "1":
                    Utility.Reveal(Application.dataPath);
                    break;
                case "2":
                    Utility.Reveal(Application.streamingAssetsPath);
                    break;
                case "3":
                    Utility.Reveal(Application.temporaryCachePath);
                    break;
                case "4":
#if UNITY_EDITOR_OSX
                    string path = GetAssetStorePackagesPathOnMac();
#elif UNITY_EDITOR_WIN
			        string path = GetAssetStorePackagesPathOnWindows();
#endif
                    Utility.Reveal(path);
                    break;
                case "5":
                    Utility.Reveal(new FileInfo(EditorApplication.applicationPath).Directory.FullName);;
                    break;
                case "6":
                    OpenEditorLogFolderPath();
                    break;
                case "7":
                    Utility.Reveal(PathManager.GetUnityPackagesFolder());
                    break;
                default:
                    break;
            }
        }

        public override IEnumerable<QuickOpenEntryMeta> GetQuickOpenEntries()
        {
            List<QuickOpenEntryMeta> metas = new List<QuickOpenEntryMeta>();
            for (int i = 0; i < SPECIAL_FOLDERS.Length; i++)
            {
                QuickOpenEntryMeta meta = new QuickOpenEntryMeta();
                meta.id = i.ToString();
                meta.label = SPECIAL_FOLDERS[i];
                meta.description = "";

                metas.Add(meta);
            }

            return metas;
        }

        private const string ASSET_STORE_FOLDER_NAME = "Asset Store-5.x";
        private string GetAssetStorePackagesPathOnMac()
        {
            var rootFolderPath = System.Environment.GetFolderPath(System.Environment.SpecialFolder.Personal);
            var libraryPath = Path.Combine(rootFolderPath, "Library");
            var unityFolder = Path.Combine(libraryPath, "Unity");
            return Path.Combine(unityFolder, ASSET_STORE_FOLDER_NAME);
        }

        private static string GetAssetStorePackagesPathOnWindows()
        {
            var rootFolderPath = System.Environment.ExpandEnvironmentVariables("%appdata%");
            var unityFolder = Path.Combine(rootFolderPath, "Unity");
            return Path.Combine(unityFolder, ASSET_STORE_FOLDER_NAME);
        }

        private void OpenEditorLogFolderPath()
        {
#if UNITY_EDITOR_OSX
            string rootFolderPath = System.Environment.GetFolderPath(System.Environment.SpecialFolder.Personal);
            var libraryPath = Path.Combine(rootFolderPath, "Library");
            var logsFolder = Path.Combine(libraryPath, "Logs");
            var UnityFolder = Path.Combine(logsFolder, "Unity");
            Utility.Reveal(UnityFolder);
#elif UNITY_EDITOR_WIN
			var rootFolderPath = System.Environment.ExpandEnvironmentVariables("%localappdata%");
			var unityFolder = Path.Combine(rootFolderPath, "Unity");
			Utility.Reveal(Path.Combine(unityFolder, "Editor"));
#endif
        }
    }
}
