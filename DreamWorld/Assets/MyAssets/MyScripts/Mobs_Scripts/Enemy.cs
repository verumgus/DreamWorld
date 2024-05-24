using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Pool;
using UnityEngine.Rendering;

public class Enemy : MonoBehaviour, IDamageable
{
    public AttackRadius AttackRadius;
    public Animator Animator;
    public AISimples Movement;
    public NavMeshAgent agent;
    public EnemyScriptableObject EnemyScriptableObject;
    public int Health = 100;
    private Coroutine LookCoroutine;


    private const string ATTACK_TRIGGER = "attack";

    private void Awake()
    {
        AttackRadius.onAttack += OnAttack;
    }

    private void OnAttack(IDamageable Target)
    {
        Animator.SetTrigger(ATTACK_TRIGGER);
        if(LookCoroutine != null )
        {
            StopCoroutine(LookCoroutine);
        }
        LookCoroutine = StartCoroutine(LookAt(Target.GetTransform()));
    }
    private IEnumerator LookAt(Transform Target)
    {
        Quaternion lookRotation = Quaternion.LookRotation(Target.position - transform.position);
        float time = 0;
        while (time < 1)
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, time);

            time += Time.deltaTime * 2;
            yield return null;
        }
        transform.rotation = lookRotation;
    }




    public virtual void OnEnable()
    {
        SetupAgengFromConfiguration();
    }

   /* public override void OnDisable()
    {
        base.OnDisable();
        agent.enabled = false;
    }
   */
    public virtual void SetupAgengFromConfiguration()
    {
        

        Health = EnemyScriptableObject.Health;
        AttackRadius.collider.radius = EnemyScriptableObject.attackRadius;
        AttackRadius.attackDelay = EnemyScriptableObject.AttackDelay;
        AttackRadius.damage = EnemyScriptableObject.Damage;

    }

    public void TakeDamager(int damage)
    {
        Health -= damage;

        if (Health < 0)
        {
            Health = 0;
            gameObject.SetActive(false);
        }
    }
    public Transform GetTransform()
    {
        return transform;
    }

}
