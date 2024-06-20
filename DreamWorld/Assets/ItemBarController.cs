using UnityEngine;
using UnityEngine.UI;

public class ItemBarController : MonoBehaviour
{
    public Image[] itemSlots; // Referência aos slots de itens
    public int selectedItemIndex = 0; // Índice do item selecionado

    void Start()
    {
        UpdateItemSelection();
    }

    void Update()
    {
        if (Input.GetAxis("Mouse ScrollWheel") > 0f)
        {
            selectedItemIndex = (selectedItemIndex + 1) % itemSlots.Length;
            UpdateItemSelection();
        }
        else if (Input.GetAxis("Mouse ScrollWheel") < 0f)
        {
            selectedItemIndex = (selectedItemIndex - 1 + itemSlots.Length) % itemSlots.Length;
            UpdateItemSelection();
        }
    }

    void UpdateItemSelection()
    {
        for (int i = 0; i < itemSlots.Length; i++)
        {
            if (i == selectedItemIndex)
            {
                itemSlots[i].color = Color.yellow; // Destacar o item selecionado
            }
            else
            {
                itemSlots[i].color = Color.white; // Cor padrão dos itens
            }
        }
    }
}
