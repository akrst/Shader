using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class styly_RenderCubemap : MonoBehaviour
{
    static public Cubemap Generate()
    {
        GameObject cubeMapCamera = new GameObject("CubemapCamera");
        Cubemap cubemap = new Cubemap(64, TextureFormat.ARGB32, true);
        var camera = cubeMapCamera.AddComponent<Camera>();
        cubeMapCamera.transform.position = Vector3.zero;
        cubeMapCamera.transform.rotation = Quaternion.identity;
        int layerMask = 0;
        camera.cullingMask = layerMask;
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(cubeMapCamera);

        return cubemap;
    }
}
