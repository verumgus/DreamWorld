using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectsColle : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        PlayerInventario playerInventario = other.GetComponent<PlayerInventario>();
        if(playerInventario != null)
        {
            playerInventario.ObjectCollected();
            gameObject.SetActive(false);
        }
    }

}
