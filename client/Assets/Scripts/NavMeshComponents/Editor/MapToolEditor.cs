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

    string[] _typeNames = { "�ֲ�", "����", "����" };
    int[] _types = { 1, 2, 3 };

    string[] _safeNames = { "��ȫ����0", "��ȫ����1", "��ȫ����2" };
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
            _relivePrefab = (GameObject)AssetDatabase.LoadAssetAtPath("Assets/NavMeshComponents/Res/�����.prefab", typeof(GameObject));
        }
    }

    public override void OnInspectorGUI()
    {
        _mapTool.m_TargetObj = EditorGUILayout.ObjectField("��ͼ����", _mapTool.m_TargetObj, typeof(GameObject), true) as GameObject;
        _mapTool.m_NavMeshSurface = EditorGUILayout.ObjectField("������", _mapTool.m_NavMeshSurface, typeof(NavMeshSurface), true) as NavMeshSurface;

        
		if (GUILayout.Button("��Ӹ����"))
		{
			AddRelivePoint();
		}

        _mapTool.m_MapId = EditorGUILayout.IntField("��ͼID:", _mapTool.m_MapId);
        _mapTool.m_MapName = EditorGUILayout.TextField("��ͼ����: ", _mapTool.m_MapName);
        //EditorGUILayout.LabelField("��ͼ��: ", _mapTool.m_MapWidth.ToString());
        //EditorGUILayout.LabelField("��ͼ��: ", _mapTool.m_MapHeight.ToString());
		_mapTool.m_OpenInStart = EditorGUILayout.Toggle("�Ƿ񿪻�������", _mapTool.m_OpenInStart);
		_mapTool.m_StartLine = EditorGUILayout.IntField("����������:", _mapTool.m_StartLine);
        _mapTool.m_MaxRole = EditorGUILayout.IntField("�������:", _mapTool.m_MaxRole);
        _mapTool.m_MapType = EditorGUILayout.IntPopup("��ͼ����: ", _mapTool.m_MapType, _typeNames, _types);
        _mapTool.m_SafeType = EditorGUILayout.IntPopup("��ͼ��ȫ����: ", _mapTool.m_SafeType, _safeNames, _safeTypes);
        _mapTool.m_CellSize = EditorGUILayout.FloatField("���Ӿ���", _mapTool.m_CellSize);
        _mapTool.m_GridX = EditorGUILayout.IntField("�Ź���X(һ�㲻Ҫ��)", _mapTool.m_GridX);
        _mapTool.m_GridY = EditorGUILayout.IntField("�Ź���Y(һ�㲻Ҫ��)", _mapTool.m_GridY);
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
            EditorUtility.DisplayDialog("��ʾ", "��ͼ����Ϊ��,���ȰѰѳ����������������棡����", "ȷ��");
            return;
        }

        if (_mapTool.m_NavMeshSurface == null)
        {
            EditorUtility.DisplayDialog("��ʾ", "������Ϊ�գ����ȰѰ�NavMeshSurface�������������棡����", "ȷ��");
            return;
        }


        if (_mapTool.m_NavMeshSurface.navMeshData == null)
        {
            EditorUtility.DisplayDialog("��ʾ", "Nav Mesh Data Ϊ�գ�����Bake����Nav Mesh Data������", "ȷ��");
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
			EditorUtility.DisplayDialog("��ʾ", "ע���ͼû�����ó�����", "ȷ��");
			return;
		}
        string walkalbe = "";
        NavMeshDataExporter.instance.Execute(_mapTool.m_NavMeshSurface, out walkalbe,out _endPos);

        // ����������ļ���ͷ
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
        Debug.Log("��������������� ->" + filepath);
        AssetDatabase.Refresh();
    }
}
