using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuManager : MonoBehaviour
{
    [SerializeField] private string levelNameScene;
    [SerializeField] private GameObject menuPainel;
    [SerializeField] private GameObject OptionPainel;

    
    public void Play()
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
        menuPainel.SetActive(true) ;
    }

    public void GameExit()
    {
        Debug.Log("Sair do Jogo Ativado");
        Application.Quit();
    }
}
