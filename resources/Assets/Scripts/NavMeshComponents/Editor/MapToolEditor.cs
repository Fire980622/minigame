using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.SceneManagement;

[CustomEditor(typeof(MapTool))]
public class MapToolEditor : Editor
{
    MapTool _mapTool;

    string[] _typeNames = { "分层", "分线", "单人" };
    int[] _types = { 1, 2, 3 };

    string[] _safeNames = { "安全级别0", "安全级别1", "安全级别2" };
    int[] _safeTypes = { 0, 1, 2 };

    Vector3 _endPos;
	GameObject _relivePrefab;

    [MenuItem("Tool/MapTool")]
    static void CreateMapTool()
    {
        var tool = GameObject.FindObjectOfType<MapTool>();
        if (tool == null)
        {
            var obj = new GameObject();
            tool = obj.AddComponent<MapTool>();
        }
        tool.name = "MapTool";
    }

	private void OnEnable()
    {
        if (_mapTool == null)
            _mapTool = target as MapTool;
        if (_relivePrefab == null)
        {
            _relivePrefab = (GameObject)AssetDatabase.LoadAssetAtPath("Assets/NavMeshComponents/Res/复活点.prefab", typeof(GameObject));
        }
    }

    public override void OnInspectorGUI()
    {
        _mapTool.m_TargetObj = EditorGUILayout.ObjectField("地图对象", _mapTool.m_TargetObj, typeof(GameObject), true) as GameObject;
        _mapTool.m_NavMeshSurface = EditorGUILayout.ObjectField("导航网", _mapTool.m_NavMeshSurface, typeof(NavMeshSurface), true) as NavMeshSurface;

        
		if (GUILayout.Button("添加复活点"))
		{
			AddRelivePoint();
		}

        _mapTool.m_MapId = EditorGUILayout.IntField("地图ID:", _mapTool.m_MapId);
        _mapTool.m_MapName = EditorGUILayout.TextField("地图名字: ", _mapTool.m_MapName);
        //EditorGUILayout.LabelField("地图宽: ", _mapTool.m_MapWidth.ToString());
        //EditorGUILayout.LabelField("地图高: ", _mapTool.m_MapHeight.ToString());
		_mapTool.m_OpenInStart = EditorGUILayout.Toggle("是否开机启动：", _mapTool.m_OpenInStart);
		_mapTool.m_StartLine = EditorGUILayout.IntField("启动分线数:", _mapTool.m_StartLine);
        _mapTool.m_MaxRole = EditorGUILayout.IntField("最大人数:", _mapTool.m_MaxRole);
        _mapTool.m_MapType = EditorGUILayout.IntPopup("地图类型: ", _mapTool.m_MapType, _typeNames, _types);
        _mapTool.m_SafeType = EditorGUILayout.IntPopup("地图安全类型: ", _mapTool.m_SafeType, _safeNames, _safeTypes);
        _mapTool.m_CellSize = EditorGUILayout.FloatField("格子精度", _mapTool.m_CellSize);
        _mapTool.m_GridX = EditorGUILayout.IntField("九宫格X(一般不要动)", _mapTool.m_GridX);
        _mapTool.m_GridY = EditorGUILayout.IntField("九宫格Y(一般不要动)", _mapTool.m_GridY);
        if (GUILayout.Button("Export Service MapData"))
        {
            ExprotMapData();
        }
    }

    private void AddRelivePoint()
    {
		GameObject obj = Instantiate(_relivePrefab, _mapTool.transform);
		_mapTool.m_Relives.Add(obj);
    }

    private void ExprotMapData()
    {
        if (_mapTool.m_TargetObj == null)
        {
            EditorUtility.DisplayDialog("提示", "地图对象为空,请先把把场景拉到对象栏里面！！！", "确定");
            return;
        }

        if (_mapTool.m_NavMeshSurface == null)
        {
            EditorUtility.DisplayDialog("提示", "导航网为空，请先把把NavMeshSurface拉到对象栏里面！！！", "确定");
            return;
        }


        if (_mapTool.m_NavMeshSurface.navMeshData == null)
        {
            EditorUtility.DisplayDialog("提示", "Nav Mesh Data 为空，请先Bake生成Nav Mesh Data！！！", "确定");
            return;
        }

        StringBuilder sb = new StringBuilder();
		sb.Append(string.Format("-module(scene_map_data_{0}).", _mapTool.m_MapId.ToString()));
		sb.Append("\n\n");
		sb.Append("-include(\"common.hrl\").\n");
		sb.Append("-include(\"scene.hrl\").");
		sb.Append("\n\n");
		sb.Append("-export(\n\t[\n\tcfg/0\n\t,walkable/0\n\t,safe_list/0\n\t,unit/0\n\t]\n).");
		sb.Append("\ncfg() ->\n\t#scene_map_data{\n\t\t");

        for (int i = 0; i < _mapTool.m_Relives.Count; i++)
        {
			if (_mapTool.m_Relives[i] == null)
			{
				_mapTool.m_Relives.RemoveAt(i);
				i--;
			}
        }

		if (_mapTool.m_Relives.Count < 1)
		{
			EditorUtility.DisplayDialog("提示", "注意地图没有设置出生点", "确定");
			return;
		}
        string walkalbe = "";
        NavMeshDataExporter.instance.Execute(_mapTool.m_NavMeshSurface, out walkalbe,out _endPos);

        // 服务端数据文件开头
        sb.Append(string.Format("base_id = {0}\n\t\t", _mapTool.m_MapId.ToString()));
		sb.Append(string.Format(",name = \"{0}\"\n\t\t", _mapTool.m_MapName));
        sb.Append(string.Format(",resname = \"{0}\"\n\t\t", _mapTool.m_TargetObj.name));
        sb.Append(string.Format(",width = {0}\n\t\t", ((Int32)(_endPos.x * 10)).ToString()));
        sb.Append(string.Format(",height = {0}\n\t\t", ((Int32)(_endPos.z * 10)).ToString()));
        sb.Append(string.Format(",startup = {0}\n\t\t", _mapTool.m_OpenInStart ? "1" : "0"));
		sb.Append(string.Format(",safe_type = {0}\n\t\t", _mapTool.m_SafeType.ToString()));
		sb.Append(string.Format(",cell_size = {{{0},{1}}}\n\t\t", ((Int32)(_mapTool.m_CellSize * 10)).ToString(), ((Int32)(_mapTool.m_CellSize * 10)).ToString()));
        //sb.Append(string.Format(",default_num = {0}\n\t\t", _mapTool.m_StartLine.ToString()));
        sb.Append(string.Format(",max_player = {0}\n\t\t", _mapTool.m_MaxRole.ToString()));
        //sb.Append(string.Format(",type = {0}\n\t\t", _mapTool.m_MapType.ToString()));
        if (_mapTool.m_MapId == 9009)
			sb.Append(string.Format(",grid_size = {{{0},{1}}}\n\t\t", Mathf.RoundToInt(20 * 10).ToString(), Mathf.RoundToInt(20 * 10).ToString()));
		else
			sb.Append(string.Format(",grid_size = {{{0},{1}}}\n\t\t", Mathf.RoundToInt(_mapTool.m_GridX * 10).ToString(), Mathf.RoundToInt(_mapTool.m_GridY * 10).ToString()));
		sb.Append(",relive = [\n\t\t\t");
		bool firstpoint = true;
		foreach (var item in _mapTool.m_Relives)
		{
			if (firstpoint)
			{
				sb.Append(string.Format("{{{0},{1}}}\n\t\t", Mathf.RoundToInt(item.transform.position.x * 10).ToString(), Mathf.RoundToInt(item.transform.position.z * 10).ToString()));
				firstpoint = false;
			}
			else
			{
				sb.Append(string.Format("\t,{{{0},{1}}}\n\t\t", Mathf.RoundToInt(item.transform.position.x * 10).ToString(), Mathf.RoundToInt(item.transform.position.z * 10).ToString()));
			}
		}
		sb.Append("]\n\t}.");
		
        
        sb.Append(walkalbe);

        string path = Application.dataPath + "/navData/";
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }

        string filepath = path + "scene_map_data_" + _mapTool.m_MapId + ".erl";
        if (File.Exists(filepath))
            File.Delete(filepath);

        FileStream stream = File.Open(filepath, FileMode.OpenOrCreate, FileAccess.ReadWrite);
        byte[] bytes = Encoding.UTF8.GetBytes(sb.ToString());
        stream.Write(bytes, 0, bytes.Length);
        stream.Close();
        stream.Dispose();
        Debug.Log("保存服务端数据完成 ->" + filepath);
        AssetDatabase.Refresh();
    }
}
