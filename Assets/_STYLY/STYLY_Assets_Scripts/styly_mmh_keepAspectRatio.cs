using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Gameobjectに貼り付けて利用することで、LocalScaleをMainTextureの縦横比に合わせます。
/// アスペクト比の正しく画像に貼り付けるSTYLYアセットのSTYLY Screenにアタッチしておく
/// </summary>
public class styly_mmh_keepAspectRatio : MonoBehaviour {	
	void Update () {
        Material m;
        if (m = GetComponent<Renderer>().material)
        {
            var x = m.mainTexture.texelSize.x;
            var y = m.mainTexture.texelSize.y;
            this.transform.localScale = new Vector3(this.transform.localScale.x, this.transform.localScale.x * (x / y), 1);
            m.mainTextureOffset = new Vector2(1, 1);
            m.mainTextureScale = new Vector2(1, 1);
        }
    }
}
