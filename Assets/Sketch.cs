using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sketch : MonoBehaviour {

	[SerializeField] private Material mat;

	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		Graphics.Blit(null, dest, mat);
	}
}
