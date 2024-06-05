using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStats : MonoBehaviour
{
    //Variaveis
    [SerializeField] private float MaxHealth;

    private float currentHealth;
    public int attackDamage;

    public HealthBar healthbar;

    // Aqui pega a vida do Player , Barra de vida dele
    void Start()
    {
        currentHealth = MaxHealth;

        healthbar.SetSliderMax(MaxHealth);
    }

    // Toma dano do inimigo teste apenas e diminuir a barra de vida
    public void TakeDamage(float Amount)
    {
        currentHealth -= Amount;
        healthbar.SetSlider(currentHealth);

    }



    //Pega o componente do inimigo(EnemyStats) e subtrai a vida dele
   public void DealDamage(GameObject Target)
   {
    var atm = Target.GetComponent<EnemyStats>();
    if(atm != null)
    {
        atm.TakeDamageEnemy(attackDamage);
    }
   }

}