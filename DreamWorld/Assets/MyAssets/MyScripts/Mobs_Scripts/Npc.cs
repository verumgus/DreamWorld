using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using static State;

[RequireComponent(typeof(NavMeshAgent))]
public class AISimples : MonoBehaviour
{
    //vida por hora
    
    //remover depois


    public FOVInimigos _cabeca;
    NavMeshAgent _navMesh;
    Transform alvo;
    Vector3 posicInicialDaAI;
    Vector3 ultimaPosicConhecida;
    float timerProcura;
    public Transform posInicial;
    public Animator animator;

    //run
    [SerializeField] private float runSpeed,walkSpeed;


    /// <Attacl>
    
    [Header("Combat")]
    [SerializeField] float attackCD, attackRange, aggroRange;
    GameObject player;
    float timePassed;
    float newDestinationCD = 0.5f;
    [SerializeField] float health = 3;
    
    /// </remover depois>

    //random Move 
    public float range; //radius of sphere
    public Transform centrePoint;


    enum estadoDaAI
    {
        parado, seguindo, procurandoAlvoPerdido
    };
    estadoDaAI _estadoAI = estadoDaAI.parado;

    void Start()
    {

        //ataque
        player = GameObject.FindWithTag("Player");
        //remover depois

        animator = GetComponent<Animator>();
        _navMesh = GetComponent<NavMeshAgent>();
        
        alvo = null;
        ultimaPosicConhecida = Vector3.zero;
        _estadoAI = estadoDaAI.parado;
        posicInicialDaAI = posInicial.position;
        timerProcura = 0;
        
    }

    void Update()
    {
        Patrol();
      
        
    }


    void Patrol()
    {
        if (_cabeca)
        {
            switch (_estadoAI)
            {
                case estadoDaAI.parado:
                    RandomMove();
                    if (_cabeca.inimigosVisiveis.Count > 0)
                    {
                        alvo = _cabeca.inimigosVisiveis[0];
                        ultimaPosicConhecida = alvo.position;
                        _estadoAI = estadoDaAI.seguindo;
                        Debug.Log("volta aqui");
                    }
                    break;
                case estadoDaAI.seguindo:
                    _navMesh.SetDestination(alvo.position);
                  
                    if (!_cabeca.inimigosVisiveis.Contains(alvo))
                    {
                        ultimaPosicConhecida = alvo.position;
                        _estadoAI = estadoDaAI.procurandoAlvoPerdido;
                        Debug.Log("corre");
                        animator.ResetTrigger("attack");
                        animator.ResetTrigger("walk");
                        _navMesh.speed = runSpeed;
                        animator.SetTrigger("run");

                       


                    }
                    break;
                case estadoDaAI.procurandoAlvoPerdido:
                    _navMesh.SetDestination(ultimaPosicConhecida);
                    timerProcura += Time.deltaTime;

                    if (timerProcura > 5)
                    {
                        timerProcura = 0;
                        _estadoAI = estadoDaAI.parado;
                        break;
                    }
                    if (_cabeca.inimigosVisiveis.Count > 0)
                    {
                        alvo = _cabeca.inimigosVisiveis[0];
                        ultimaPosicConhecida = alvo.position;
                        _estadoAI = estadoDaAI.seguindo;

                        Debug.Log("cade Ele");
                    }
                    break;
            }
        }
    }
    void Attack()
    {
        //animator.SetFloat("run", _navMesh.velocity.magnitude / _navMesh.speed); 
        //animator.SetTrigger("walk");
        if (timePassed >= attackCD)
        {
            if (Vector3.Distance(player.transform.position, transform.position) <= attackRange)
            {
                animator.ResetTrigger("walk");
                animator.ResetTrigger("run");
                animator.SetTrigger("attack");
                timePassed = 0;
            }
        }
        timePassed += Time.deltaTime;
       // Move();
    }

    
    void Move()
    {
        if(newDestinationCD<=0 && Vector3.Distance(player.transform.position,transform.position) <= aggroRange)
        {
            newDestinationCD = 0.5f;
            _navMesh.SetDestination(player.transform.position);
        }
        newDestinationCD -=Time.deltaTime;
        transform.LookAt(player.transform);
    }


    public void RandomMove()
    {
        if (_navMesh.remainingDistance <= _navMesh.stoppingDistance) //done with path
        {
            Vector3 point;
            if (RandomPoint(centrePoint.position, range, out point)) //pass in our centre point and radius of area
            {
                animator.ResetTrigger("attack");
                animator.ResetTrigger("run");
                _navMesh.speed = walkSpeed;
                animator.SetTrigger("walk");
                Debug.DrawRay(point, Vector3.up, Color.blue, 1.0f); //so you can see with gizmos
                _navMesh.SetDestination(point);
            }
        }
    }



    bool RandomPoint(Vector3 center, float range, out Vector3 result)
    {

        Vector3 randomPoint = center + Random.insideUnitSphere * range; //random point in a sphere 
        NavMeshHit hit;
        if (NavMesh.SamplePosition(randomPoint, out hit, 1.0f, NavMesh.AllAreas)) //documentation: https://docs.unity3d.com/ScriptReference/AI.NavMesh.SamplePosition.html
        {
            //the 1.0f is the max distance from the random point to a point on the navmesh, might want to increase if range is big
            //or add a for loop like in the documentation
            result = hit.position;
            return true;
        }
       
        animator.ResetTrigger("run");
        animator.SetTrigger("walk");
        result = Vector3.zero;
        return false;
    }


    //ataque
    public void TakeDamage(float damage)
    {
        health -= damage;
        //animator.SetTrigger("damage");
        if(health < 0)
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
            
    }

}
