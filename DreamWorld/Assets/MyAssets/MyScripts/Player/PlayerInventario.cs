using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class PlayerInventario : MonoBehaviour
{
    public int NumberOfObject {  get; private set; }

    public UnityEvent<PlayerInventario> OnObjectCollected;

    public void ObjectCollected()
    {
        NumberOfObject++;
        OnObjectCollected?.Invoke(this);
    }
  
}
