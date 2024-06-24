using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DialogueManager : MonoBehaviour
{
    public Text dialogueText;
    public GameObject dialoguePanel;
    public string[] dialogueLines;
    private int currentLineIndex = 0;

    void Start()
    {
        dialoguePanel.SetActive(false); // Ensure the dialogue panel is initially hidden
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.T) && dialoguePanel.activeSelf)
        {
            DisplayNextLine();
        }
    }

    public void StartDialogue(string[] lines)
    {
        dialogueLines = lines;
        currentLineIndex = 0;
        dialoguePanel.SetActive(true);
        DisplayNextLine();
    }

    public void DisplayNextLine()
    {
        if (currentLineIndex < dialogueLines.Length)
        {
            dialogueText.text = dialogueLines[currentLineIndex];
            currentLineIndex++;
        }
        else
        {
            EndDialogue();
        }
    }

    public void EndDialogue()
    {
        dialoguePanel.SetActive(false);
    }
}
