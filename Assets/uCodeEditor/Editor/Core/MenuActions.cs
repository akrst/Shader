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
    public class MenuActions
    {
        [UnityEditor.MenuItem("Assets/Open In uCodeEditor %j", false, 66)]
        private static void OpenInUE()
        {
            var result = ShowContentInUE(Selection.activeObject);
            if (result.HasValue)
            {
                if (result.Value)
                {
                    MainWindow.LoadWindow();
                }
                else
                {
                    EditorUtility.DisplayDialog("Not Support", "This asset is not supported!", "Ok");
                }
            }
        }

        [UnityEditor.MenuItem("Assets/Open In uCodeEditor %j", true)]
        private static bool OpenInUEEnable()
        {
            var path = AssetDatabase.GetAssetPath(Selection.activeObject);
            if (!string.IsNullOrEmpty(path))
            {
                return Utility.IsFileAllowed(path);
            }

            return false;
        }

        /// <summary>
        /// Show selected asset content in uCodeEditor
        /// </summary>
        /// <param name="asset">The selected object</param>
        /// <param name="openNew">Open new tab or not</param>
        public static bool? ShowContentInUE(Object asset, bool openNew = true)
        {
            if (asset == null)
            {
                return null;
            }

            var path = AssetDatabase.GetAssetPath(asset);
            if (Utility.IsFileAllowed(path) && MainWindow.CommunicateServices != null)
            {
                MainWindow.CommunicateServices.UEOpenFile(path, openNew);
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}