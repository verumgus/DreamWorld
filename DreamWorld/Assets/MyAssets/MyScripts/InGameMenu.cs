using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class InGameMenu : MonoBehaviour
{
    
    [SerializeField] private string levelNameScene;
    [SerializeField] private GameObject menuPainel;
    [SerializeField] private GameObject OptionPainel;
    [SerializeField] private  GameObject inPauseMenu;
    public int PauseState = 0;


    private void Awake()
    {
        Time.timeScale = 1;
    }

    public void Update()
    {
        if(Input.GetKeyDown(KeyCode.Tab)) 
        {
            if(PauseState == 0)
            {
                Pause();
            }
            else if(PauseState == 1)

            {
                Continue();
            }

        }
    }

    public void Pause()
    {
        inPauseMenu.SetActive(true);
        Time.timeScale = 0;
        PauseState++;
        Cursor.lockState = CursorLockMode.None;
    }

    public void Continue()
    {
        PauseState--;
        inPauseMenu.SetActive(false);
        Time.timeScale = 1;
        Cursor.lockState = CursorLockMode.Locked;
    }

    public void OpenMainManu()
    {
        SceneManager.LoadScene(levelNameScene);
    }

    public void OpenOption()
    {
        menuPainel.SetActive(false);
        OptionPainel.SetActive(true);
    }

    public void CloseOption()
    {
        OptionPainel.SetActive(false);
        menuPainel.SetActive(true);
    }



    public void GameExit()
    {
        Debug.Log("Sair do Jogo Ativado");
        Application.Quit();
    }
}
