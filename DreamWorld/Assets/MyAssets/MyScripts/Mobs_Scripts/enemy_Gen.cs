using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class enemy_Gen : MonoBehaviour
{

    Animator animator;
    NavMeshAgent agent;
    GameObject player;

    [Header("Combat")]
    [SerializeField] float attackCD, attackRange, aggroRange;
    
    float timePassed;
    float newDestinationCD = 0.5f;
    [SerializeField] float health = 3;

    // Start is called before the first frame update
    void Start()
    {
        player = GameObject.FindWithTag("Player");
        agent  = GetComponent<NavMeshAgent>();

        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        Attack();
    }

    void Attack()
    {
       animator.SetFloat("speed", agent.velocity.magnitude / agent.speed); 
        //animator.SetTrigger("walk");
        if (timePassed >= attackCD)
        {
            if (Vector3.Distance(player.transform.position, transform.position) <= attackRange)
            {
                
                animator.SetTrigger("attack");
                timePassed = 0;
            }
        }
        timePassed += Time.deltaTime;
         Move();
    }


    void Move()
    {
        if (newDestinationCD <= 0 && Vector3.Distance(player.transform.position, transform.position) <= aggroRange)
        {
            newDestinationCD = 0.5f;
            agent.SetDestination(player.transform.position);
        }
        if (newDestinationCD <= 0 && Vector3.Distance(player.transform.position, transform.position) <= aggroRange+10)
        {
            
            transform.LookAt(player.transform);
        }
        newDestinationCD -= Time.deltaTime;

    }

    public void TakeDamage(float damage)
    {
        health -= damage;
        animator.SetTrigger("damage");
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
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, aggroRange);
        Gizmos.color = Color.white;
        Gizmos.DrawWireSphere(transform.position,aggroRange+10);

    }
}
