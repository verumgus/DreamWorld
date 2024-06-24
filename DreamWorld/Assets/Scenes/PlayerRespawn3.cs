using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerRespawn3 : MonoBehaviour
{
    public Transform respawnPoint; // Ponto de respawn

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Ground"))
        {
            Respawn();
        }
    }

    void Respawn()
    {
        transform.position = respawnPoint.position;
        // Você pode adicionar mais lógica aqui, como redefinir a velocidade do jogador
    }
}
