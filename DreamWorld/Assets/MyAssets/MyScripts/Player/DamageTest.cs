using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamageTest : MonoBehaviour
{
    public PlayerStats playerAtm;
    public EnemyStats enemyAtm;

    // Update is called once per frame
    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.Y))
        {
           playerAtm.DealDamage(enemyAtm.gameObject);
        }

        if(Input.GetKeyDown(KeyCode.U))
        {
           enemyAtm.DealDamageEnemy(playerAtm.gameObject);
        }
    }
}
