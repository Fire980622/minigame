using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.SceneManagement;

public class NavMeshDataExporter : ScriptableSingleton<NavMeshDataExporter>
{
    const int CELL_SIZE = 1;
	const string LAYER_NAME = "NavMesh";
	public void Execute(Object Obj,out string walkable ,out Vector3 endPos)
    {
		NavMeshTriangulation triangulatedNavMesh = NavMesh.CalculateTriangulation();
		NavMeshSurface meshSurface = Obj as NavMeshSurface;
		GameObject target = meshSurface.gameObject;
		AddOrCreateLayerForGameObject(LAYER_NAME, target);

        for (int i = 0; i < triangulatedNavMesh.vertices.Length; i++)
        {
			triangulatedNavMesh.vertices[i] = target.transform.worldToLocalMatrix.MultiplyPoint(triangulatedNavMesh.vertices[i]);
		}

		Mesh navmesh = new Mesh();
		navmesh.name = "_NavMesh";
		navmesh.vertices = triangulatedNavMesh.vertices;
		navmesh.triangles = triangulatedNavMesh.indices;
		var collider = target.GetComponent<MeshCollider>();
		if (collider == null)
		{
			collider = target.AddComponent<MeshCollider>();
		}
		
		collider.sharedMesh = navmesh;

		Vector3[] localVectors = navmesh.vertices;
		int[] triangles = navmesh.triangles;
		//把mesh的本地坐标转成世界坐标
		Vector3[] worldVectors = new Vector3[localVectors.Length];
		float minx = Mathf.Infinity;
		float miny = Mathf.Infinity;
		float maxx = -Mathf.Infinity;
		float maxy = -Mathf.Infinity;
		for (int i = 0; i < localVectors.Length; ++i)
		{
			Vector3 pos = target.transform.TransformPoint(localVectors[i]);
			worldVectors[i] = pos;
			if (pos.x < minx)
				minx = pos.x;
			if (pos.x > maxx)
				maxx = pos.x;
			if (pos.z < miny)
				miny = pos.z;
			if (pos.z > maxy)
				maxy = pos.z;
		}
		
		List<List<Vector4>> digitalList = new List<List<Vector4>>();
		Vector3 start = new Vector3(minx, 0, miny);
		Vector3 end = new Vector3(maxx, 0, maxy);

		Debug.Log(string.Format("start = {0} end = {1}", start, end));


		float zeroX = start.x;
		float zeroY = start.z;

		float maxX = end.x;
		float maxY = end.z;

		float initX = Mathf.RoundToInt(zeroX);
		float initY = Mathf.RoundToInt(zeroY);
		float loopX = initX;
		float loopY = initY;
		int pointnum = 0;
		while (loopY < maxY)
		{
			loopX = initX;
			List<Vector4> xList = new List<Vector4>();
			digitalList.Add(xList);
			while (loopX < maxX)
			{
				if (AddRayPoint(loopX, loopY, xList))
					pointnum++;
				loopX += CELL_SIZE;
			}
			loopY += CELL_SIZE;
		}
		
		Debug.Log("服务端可行走点个数：" + pointnum.ToString());
		if (pointnum > 100000)
			EditorUtility.DisplayDialog("提示", "生成可行走点数超过10万个，注意检查是否正常！start:" + start.ToString() + " end:" + end.ToString(), "确定");
		walkable = GetWalkableString(start,digitalList);
		endPos = end;
		DestroyImmediate(collider);
	}
	private bool AddRayPoint(float x, float y, List<Vector4> list)
	{
		Vector3 origin = new Vector3(x, 1000000, y);
		float halfsize = CELL_SIZE / 2f;
		Vector3 direction = new Vector3(0, -10000, 0);
		RaycastHit raycastHit;
		LayerMask layerMask = LayerMask.GetMask(LAYER_NAME);
		
		if (Physics.Raycast(origin, direction, out raycastHit, Mathf.Infinity, layerMask))
		{
			Vector3 lb = new Vector3(origin.x - halfsize, origin.y, origin.z - halfsize);
			if (!Physics.Raycast(lb, direction, Mathf.Infinity, layerMask))
			{
				list.Add(new Vector4(raycastHit.point.x, raycastHit.point.y, raycastHit.point.z));
				return false;
			}
			Vector3 rb = new Vector3(origin.x + halfsize, origin.y, origin.z - halfsize);
			if (!Physics.Raycast(rb, direction, Mathf.Infinity, layerMask))
			{
				list.Add(new Vector4(raycastHit.point.x, raycastHit.point.y, raycastHit.point.z));
				return false;
			}
			Vector3 lt = new Vector3(origin.x - halfsize, origin.y, origin.z + halfsize);
			if (!Physics.Raycast(lt, direction, Mathf.Infinity, layerMask))
			{
				list.Add(new Vector4(raycastHit.point.x, raycastHit.point.y, raycastHit.point.z));
				return false;
			}
			Vector3 rt = new Vector3(origin.x + halfsize, origin.y, origin.z + halfsize);
			if (!Physics.Raycast(rt, direction, Mathf.Infinity, layerMask))
			{
				list.Add(new Vector4(raycastHit.point.x, raycastHit.point.y, raycastHit.point.z));
				return false;
			}

			list.Add(new Vector4(raycastHit.point.x, raycastHit.point.y, raycastHit.point.z, 1));
			
			return true;
		}

		list.Add(new Vector4(raycastHit.point.x, raycastHit.point.y, raycastHit.point.z));

		return false;
	}

	private string GetWalkableString(Vector3 start, List<List<Vector4>> digitalList)
    {
		StringBuilder sb = new StringBuilder();
		sb.Append("\n\nwalkable() ->\n\t[");
		int gsx = Mathf.RoundToInt(start.x / CELL_SIZE);
		int gsy = Mathf.RoundToInt(start.z / CELL_SIZE);
		bool first = true;
		int num = 0;
		int size = digitalList.Count;
		//保存服务端格子信息
		for (int i = 0; i < size; i++)
		{
			List<Vector4> DataList = digitalList[i];
			for (int j = 0; j < DataList.Count; j++)
			{
				if (DataList[j].w == 0)
					continue;

				num++;
				if (first)
				{
					sb.Append(string.Format("{{{0},{1},0}}", (j + gsx).ToString(), (i + gsy).ToString()));
					first = false;
				}
				else
				{
					sb.Append(string.Format(",{{{0},{1},0}}", (j + gsx).ToString(), (i + gsy).ToString()));
				}
				if (num % 8 == 0)
					sb.Append("\n");
			}
		}
		sb.Append("].");
		return sb.ToString();
		//string path = Application.dataPath + "/navData/";
		//if (!Directory.Exists(path))
		//{
		//	Directory.CreateDirectory(path);
		//}
		
		//string filepath = path + "scene_navmesh_data_" + SceneManager.GetActiveScene().name + ".bytes";
		//if (File.Exists(filepath))
		//	File.Delete(filepath);

		//FileStream stream = File.Open(filepath, FileMode.OpenOrCreate, FileAccess.ReadWrite);
		//byte[] bytes = Encoding.UTF8.GetBytes(sb.ToString());
		//stream.Write(bytes, 0, bytes.Length);
		//stream.Close();
		//stream.Dispose();
		//Debug.Log("保存服务端数据完成 ->" + filepath);
		//AssetDatabase.Refresh();
	}



	private void AddOrCreateLayerForGameObject(string layer,GameObject obj)
	{
		if (!IsHasLayer(layer))
		{
			SerializedObject tagManager = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
			SerializedProperty it = tagManager.GetIterator();
            while (it.NextVisible(true))
            {
				if (it.name == "layers")
				{
                    for (int i = 8; i < it.arraySize; i++)
                    {
						SerializedProperty sp = it.GetArrayElementAtIndex(i);
						if (string.IsNullOrEmpty(sp.stringValue))
						{
							sp.stringValue = layer;
							tagManager.ApplyModifiedProperties();
							break;
						}
                    }
					break;
				}
            }
        }

		obj.layer = LayerMask.NameToLayer(layer);
	}

	private bool IsHasLayer(string layer)
	{
		for (int i = 0; i < UnityEditorInternal.InternalEditorUtility.layers.Length; i++)
		{
			if (UnityEditorInternal.InternalEditorUtility.layers[i].Contains(layer))
				return true;
		}
		return false;
	}
}
