//  Copyright (c) 2018-present amlovey
//  
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

namespace uCodeEditor
{
    public class LocalSettings
    {
        private const string SETTINGS_FILE = "settings.json";

        /// <summary>
        /// Get content of local settings
        /// </summary>
        /// <returns>Setting content</returns>
        public static string GetLocalSettingsPath()
        {
            string settingFile = Utility.PathCombine(GetOrCreateLocalSettingsFolder(), SETTINGS_FILE);
            if (!File.Exists(settingFile))
            {
                SaveLocalSettings("{}");
            }
            
            return settingFile;
        }

        /// <summary>
        /// Save sttings to local
        /// </summary>
        /// <param name="settingsJson">Json string of settings</param>
        public static void SaveLocalSettings(string settingsJson)
        {
            string settingFile = Utility.PathCombine(GetOrCreateLocalSettingsFolder(), SETTINGS_FILE);
            File.WriteAllText(settingFile, settingsJson);
        }

        /// <summary>
        /// Get path of local settings folder
        /// </summary>
        /// <returns>Local settings folder</returns>
        public static string GetOrCreateLocalSettingsFolder()
        {
            string folder = Utility.PathCombine(Application.dataPath, "..", ".uce");
			Directory.CreateDirectory(folder);
			return folder;
        }
    }
}