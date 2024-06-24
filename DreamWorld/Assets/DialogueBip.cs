using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DialogueBip : MonoBehaviour
{
    public string[] dialogueLines;
    private DialogueManager dialogueManager;

    void Start()
    {
        dialogueManager = FindObjectOfType<DialogueManager>();
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            dialogueManager.StartDialogue(dialogueLines);
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            dialogueManager.EndDialogue();
        }
    }
}
