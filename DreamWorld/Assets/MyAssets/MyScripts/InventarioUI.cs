using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class InventarioUI : MonoBehaviour

{
    private TextMeshProUGUI objectText;
    private int saveCont;
    void Start()
    {
        
        objectText = GetComponent<TextMeshProUGUI>();       
        saveCont = PlayerPrefs.GetInt("NumberOfObject");
        objectText.text = saveCont.ToString();

    }


    public void UpdateObjectText(PlayerInventario playerInventario)
    {

        if (playerInventario.NumberOfObject == 4)
        {
            objectText.color = Color.green;
            
        }
        objectText.text = playerInventario.NumberOfObject.ToString();
        

    }

  
    
}
