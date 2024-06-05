using System.Collections;
using System.Collections.Generic;
using Unity.PlasticSCM.Editor.WebApi;
using UnityEngine;

public class EnemyStats : MonoBehaviour
{

    [SerializeField] private float MaxHealthEnemy;

    private float currentHealthEnemy;
    public int attackDamageEnemy;


    // Start is called before the first frame update
    void Start()
    {
        currentHealthEnemy = MaxHealthEnemy;
        
        
    }


    public void TakeDamageEnemy(float Amount)
    {
        currentHealthEnemy -= Amount;
    }

    public void DealDamageEnemy(GameObject Target)
    {
        var atm = Target.GetComponent<PlayerStats>();
        if(atm != null)
        {
            atm.TakeDamage(attackDamageEnemy);
        }
    }
}
