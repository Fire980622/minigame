using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[ExecuteInEditMode]
public class MapTool : MonoBehaviour
{
    public GameObject m_TargetObj;
    public NavMeshSurface m_NavMeshSurface;

    public int m_MapId;                     //��ͼID
    public string m_MapName;                //��ͼ����
    //public int m_MapHeight;                 //��ͼ��
    //public int m_MapWidth;                  //��ͼ��
    public bool m_OpenInStart = true;       //�Ƿ񿪻�����
    public int m_StartLine = 5;                 //����������
    public int m_MaxRole = 100;                   //�������
    public int m_MapType = 2;                   //��ͼ����
    public int m_SafeType = 0;                  //��ͼ��ȫ����
    public float m_CellSize = 1;                //���Ӿ���
    public int m_GridX = 18;                     //�Ź���X��һ�㲻Ҫ����
    public int m_GridY = 15;                     //�Ź���Y��һ�㲻Ҫ����
    public List<GameObject> m_Relives = new List<GameObject>();      //�����

    private void Awake()
    {
        if (m_NavMeshSurface == null)
        {
            m_NavMeshSurface = GetComponent<NavMeshSurface>();
        }
    }
}
