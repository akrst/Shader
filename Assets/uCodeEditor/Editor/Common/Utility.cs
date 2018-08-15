﻿//  Copyright (c) 2018-present amlovey
//  
using System;
using System.Text;
using System.IO;
using System.Linq;
using System.Collections.Generic;

namespace uCodeEditor
{
    public class Utility
    {
        public static string ConvertToBase64(string content)
        {
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(Uri.EscapeDataString(content)));
        }

        public static string FromBase64(string content)
        {
            return Uri.UnescapeDataString(Encoding.UTF8.GetString(Convert.FromBase64String(content)));
        }

        public static string MD5(string input)
        {
            System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create();
            byte[] inputBytes = System.Text.Encoding.ASCII.GetBytes(input);
            byte[] hash = md5.ComputeHash(inputBytes);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < hash.Length; i++)
            {
                sb.Append(hash[i].ToString("X2"));
            }
            return sb.ToString();
        }

        public static void Unpack(string filePath, string dst)
        {
            if (string.IsNullOrEmpty(filePath) || string.IsNullOrEmpty(dst) || !File.Exists(filePath))
            {
                return;
            }

            string content = File.ReadAllText(filePath);
            File.WriteAllBytes(dst, Convert.FromBase64String(content));
        }

        public static void Pack(string src, string dst)
        {
            if (string.IsNullOrEmpty(src) || string.IsNullOrEmpty(dst) || !File.Exists(src))
            {
                return;
            }

            byte[] bytes = File.ReadAllBytes(src);
            File.WriteAllText(dst, Convert.ToBase64String(bytes));
        }

        public static string GetFileMD5(string path)
        {
            if (!File.Exists(path))
            {
                return null;
            }

            return MD5(File.ReadAllText(path));
        }

        public static void Log(object msg)
        {
#if uCE_DEV
            UnityEngine.Debug.Log(msg);
#endif
        }

        public static void LogWithName(object msg)
        {
            UnityEngine.Debug.Log(string.Format("[uCodeEditor] {0}", msg.ToString()));
        }

        public static string PathCombine(params string[] parts)
        {
            var path = parts[0];
            for (var i = 1; i < parts.Length; ++i)
            {
                path = Path.Combine(path, parts[i]);
            }

            return path;
        }

        public static bool IsCSharpScript(string path)
        {
            if (IsDirectory(path))
            {
                return false;
            }

            var lowerPath = path.ToLower();
            return lowerPath.EndsWith(".cs") || lowerPath.EndsWith(".csx");
        }

        public static string PathNormalized(string path)
        {
            return path.Replace("\\", "/");
        }

        public static List<string> GetAllAllowedFiles(string folder)
        {
            var files = new List<string>();
            foreach (var item in Directory.GetFiles(folder, "*.*", SearchOption.AllDirectories))
            {
                if (item.ToString().EndsWith(".meta")) 
                {
                    continue;    
                }

                if (Constants.ALLOWED_FILE_EXTENSIONS.Contains(Path.GetExtension(item).ToLower()))
                {
                    files.Add(item);
                }
            }

            return files;
        }

        public static bool IsFileAllowed(string path)
        {
            if (IsDirectory(path))
            {
                return false;
            }

            return Constants.ALLOWED_FILE_EXTENSIONS.Any(fe => path.ToLower().EndsWith(fe));
        }

        public static string EscapeJson(string str)
        {
            if (string.IsNullOrEmpty(str))
            {
                return str;
            }

            string escape = str.Replace("\\", "\\\\");
            escape = escape.Replace("\b", "\\b");
            escape = escape.Replace("\f", "\\f");
            escape = escape.Replace("\r", "\\r");
            escape = escape.Replace("\n", "\\n");
            escape = escape.Replace("\"", "\\\"");
            escape = escape.Replace("\t", "\\t");

            return escape;
        }

        public static string EscapeRegularExpression(string text)
        {
            string escapedText = text;
            escapedText = escapedText.Replace("\\", "\\\\");
            escapedText = escapedText.Replace("*", "\\*");
            escapedText = escapedText.Replace("?", "\\?");
            escapedText = escapedText.Replace("^", "\\^");
            escapedText = escapedText.Replace("$", "\\$");
            escapedText = escapedText.Replace("+", "\\+");
            escapedText = escapedText.Replace("(", "\\(");
            escapedText = escapedText.Replace(")", "\\)");
            escapedText = escapedText.Replace("[", "\\]");
            escapedText = escapedText.Replace("]", "\\]");
            escapedText = escapedText.Replace("{", "\\{");
            escapedText = escapedText.Replace("}", "\\}");
            escapedText = escapedText.Replace(".", "\\.");
            escapedText = escapedText.Replace("|", "\\|");
            return escapedText;
        }

        public static bool IsDirectory(string path)
        {
            if (string.IsNullOrEmpty(path))
            {
                return false;
            }

            try
            {
                // sometimes the path is not exists, this line will throw exception
                return (File.GetAttributes(path) & FileAttributes.Directory) == FileAttributes.Directory;
            }
            catch
            {
                return false;
            }
        }

        public static void StarAndReview()
        {
            UnityEditorInternal.AssetStore.Open(Constants.ASSET_ID);
        }

        public static void Reveal(string folderPath)
		{
			if(!Directory.Exists(folderPath))
			{
				return;
			}

			UnityEditor.EditorUtility.RevealInFinder(folderPath);
		}
    }
}