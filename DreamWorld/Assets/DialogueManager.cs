using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DialogueManager : MonoBehaviour
{
    public Text dialogueText;
    public GameObject dialoguePanel;
    private string[] dialogueLines;
    private int currentLineIndex = 0;

    void Start()
    {
        // dialoguePanel.SetActive(false); // Desativado para iniciar automaticamente na cena inicial
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) && dialoguePanel.activeSelf)
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

    public void StartAutomaticDialogue(string[] lines)
    {
        dialogueLines = lines;
        currentLineIndex = 0;
        dialoguePanel.SetActive(true);
        DisplayNextLine();
    }
}
