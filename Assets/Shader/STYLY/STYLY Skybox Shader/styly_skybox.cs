using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class styly_skybox : MonoBehaviour
{

    public Material skybox;
    public Cubemap cubemap;

    // Use this for initialization

    void OnEnable()
    {
        StartCoroutine(ApplySkyBox());
    }

    void OnDisable()
    {
        OnDestroy();
    }

    public IEnumerator ApplySkyBox()
    {
        //STYLYアセットのおまじない。2フレーム待機。
        yield return null; yield return null;

        //Main
        StartCoroutine(MainRoutine());
    }

    /// <summary>
    /// メインルーチン
    /// </summary>
    private IEnumerator MainRoutine()
    {
        RenderSettings.skybox = skybox;

        yield return null;

        RenderSettings.defaultReflectionMode = UnityEngine.Rendering.DefaultReflectionMode.Custom;

        cubemap = styly_RenderCubemap.Generate();
        
        RenderSettings.customReflection = cubemap;
        yield return null;
    }

    void OnDestroy()
    {
#if UNITY_STANDALONE
//        if (SceneManager.GetActiveScene().name != STYLY.STYLY_INI.STYLY_HOME_SCENE)
        {
            RenderSettings.skybox = null;
            RenderSettings.customReflection = null;
        }
#else
        RenderSettings.skybox = null;
        RenderSettings.customReflection = null;
#endif
    }
}
