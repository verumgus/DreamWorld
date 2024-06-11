using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class PlayerInventario : MonoBehaviour
{
    public int NumberOfObject {  get; private set; }

    public int SaveAllObject;

    public UnityEvent<PlayerInventario> OnObjectCollected;


    private void Start()
    {
        SaveAllObject = PlayerPrefs.GetInt("NumberOfObject");
        Debug.Log(PlayerPrefs.GetInt("NumberOfObject"));
    }
    public void ObjectCollected()
    {

        //teste
        SaveAllObject++;
        PlayerPrefs.SetInt("NumberOfObject", SaveAllObject);
        //teste
        NumberOfObject = SaveAllObject;
        OnObjectCollected?.Invoke(this);
        
        
    }
  
}
