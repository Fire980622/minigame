using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[ExecuteInEditMode]
public class MapTool : MonoBehaviour
{
    public GameObject m_TargetObj;
    public NavMeshSurface m_NavMeshSurface;

    public int m_MapId;                     //地图ID
    public string m_MapName;                //地图名字
    //public int m_MapHeight;                 //地图高
    //public int m_MapWidth;                  //地图宽
    public bool m_OpenInStart = true;       //是否开机启动
    public int m_StartLine = 5;                 //启动分数线
    public int m_MaxRole = 100;                   //最大人数
    public int m_MapType = 2;                   //地图类型
    public int m_SafeType = 0;                  //地图安全类型
    public float m_CellSize = 1;                //格子精度
    public int m_GridX = 18;                     //九宫格X（一般不要动）
    public int m_GridY = 15;                     //九宫格Y（一般不要动）
    public List<GameObject> m_Relives = new List<GameObject>();      //复活点

    private void Awake()
    {
        if (m_NavMeshSurface == null)
        {
            m_NavMeshSurface = GetComponent<NavMeshSurface>();
        }
    }
}
