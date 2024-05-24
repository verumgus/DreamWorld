using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class TerraCota_Attack : MonoBehaviour
{

    public Animator animator;
    [Header("Combat")]
    [SerializeField] float attackCD, attackRange, aggroRange;
    GameObject player;
    float timePassed;
    float newDestinationCD = 0.5f;
    [SerializeField] float health = 3;
    void Start()
    {
        player = GameObject.FindWithTag("Player");
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        Attack();
    }

    void Attack()
    {
        
        if (timePassed >= attackCD)
        {
            if (Vector3.Distance(player.transform.position, transform.position) <= attackRange)
            {

                animator.SetTrigger("attack");
                timePassed = 0;

            }
            
        }
        timePassed += Time.deltaTime;
        // Move();
    }

    void Move()
    {
        if (newDestinationCD <= 0 && Vector3.Distance(player.transform.position, transform.position) <= aggroRange)
        {
            newDestinationCD = 0.5f;
            
        }
        newDestinationCD -= Time.deltaTime;
        transform.LookAt(player.transform);
    }

    //ataque
    public void TakeDamage(float damage)
    {
        health -= damage;
        //animator.SetTrigger("damage");
        if (health < 0)
        {
            health = 0;
            Die();
        }
    }
    void Die()
    {
        Destroy(this.gameObject);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackRange);
        

    }
}
