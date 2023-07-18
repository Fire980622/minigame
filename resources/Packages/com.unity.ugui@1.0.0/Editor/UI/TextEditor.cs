using UnityEngine;
using UnityEngine.UI;

namespace UnityEditor.UI
{
    [CustomEditor(typeof(Text), true)]
    [CanEditMultipleObjects]
    /// <summary>
    /// Custom Editor for the Text Component.
    /// Extend this class to write a custom editor for a component derived from Text.
    /// </summary>
    public class TextEditor : GraphicEditor
    {
        SerializedProperty m_Text;
        SerializedProperty m_FontData;
        SerializedProperty m_Grey;
        SerializedProperty m_LangId;
        SerializedProperty m_FontKey;

        protected override void OnEnable()
        {
            base.OnEnable();
            m_Text = serializedObject.FindProperty("m_Text");
            m_FontData = serializedObject.FindProperty("m_FontData");
            m_Grey = serializedObject.FindProperty("m_Grey");
            m_FontKey = serializedObject.FindProperty("fontKey");
            m_LangId = serializedObject.FindProperty("langId");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            if (m_FontKey != null) EditorGUILayout.PropertyField(m_FontKey);
            if (m_LangId != null) EditorGUILayout.PropertyField(m_LangId);

            EditorGUILayout.PropertyField(m_Text);
            EditorGUILayout.PropertyField(m_FontData);

            if (m_Grey != null) EditorGUILayout.PropertyField(m_Grey);
            AppearanceControlsGUI();
            RaycastControlsGUI();
            MaskableControlsGUI();
            serializedObject.ApplyModifiedProperties();
        }
    }
}
