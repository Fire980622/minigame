using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Image image = GetComponent<Image>();
        Sprite sprite = image.sprite;
        Vector2[] vertices = sprite.vertices;
        Debug.Log(vertices.Length);
        Debug.Log(image.gameObject);
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
