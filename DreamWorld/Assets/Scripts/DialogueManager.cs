using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DialogueManager : MonoBehaviour
{

    public Text nameText;
    public Text dialogueText;

    private Queue<string> sentences;

    // Start is called before the first frame update
    void Start()
    {
        sentences = new Queue<string>();
    }

    public void StartDialogue(Dialogue dialogue)
    {
        Debug.Log("Log baby" + dialogue.name);

        nameText.text = dialogue.name;

        sentences.Clear();
        
        foreach (string sentence in dialogue.sentences)
        {
            sentences.Enqueue(sentence);
        }

        DisplayNextSetences();
    }

    public void DisplayNextSetences()
    {
        if(sentences.Count == 0)
        {
            EndDialogue();
            return;
        }

        string setence = sentences.Dequeue();
        Debug.Log(setence);
        dialogueText.text = setence;


    }

    public void EndDialogue()
    {
        Debug.Log("Over");
    }

}
