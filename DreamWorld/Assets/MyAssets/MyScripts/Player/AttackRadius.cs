using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(SphereCollider))]
public class AttackRadius : MonoBehaviour
{
    public SphereCollider collider;
    private List<IDamageable> Damagebles = new List<IDamageable>();
    public int damage = 10;
    public float attackDelay = 0.5f;
    public delegate void AttackEvent(IDamageable target);
    public AttackEvent onAttack;
    private Coroutine attackCoroutine;



    private void Awake()
    {
        collider = GetComponent<SphereCollider>();
    }



    private void OnTriggerEnter(Collider other)
    {
        IDamageable damageble = other.GetComponent<IDamageable>();
        if(damageble != null)
        {
            Damagebles.Add(damageble);

            if(attackCoroutine == null)
            {
                attackCoroutine = StartCoroutine(Attack());
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        IDamageable damageble = other.GetComponent<IDamageable>();
        if (damageble != null)
        {
            Damagebles.Remove(damageble);

            if (Damagebles.Count == 0)
            {
               StopCoroutine(attackCoroutine);
                attackCoroutine = null;
            }
        }
    }

    private IEnumerator Attack()
    {
        WaitForSeconds Wait = new WaitForSeconds(attackDelay);

        yield return Wait;

        IDamageable closestDamageble = null;
        float closestDistance = float.MaxValue;

        while(Damagebles.Count>0)
        {
            for(int i = 0; i < Damagebles.Count; i++)
            {
                Transform damableTransform = Damagebles[i].GetTransform();
                float distance = Vector3.Distance(transform.position, damableTransform.position);

                if(distance < closestDistance)
                {
                    closestDistance = distance;
                    closestDamageble = Damagebles[i];

                }
            }
            if (closestDamageble != null)
            {
                onAttack?.Invoke(closestDamageble);
                closestDamageble.TakeDamager(damage);
            }
            closestDamageble = null;
            closestDistance = float.MaxValue;

            yield return Wait;


            Damagebles.RemoveAll(DisabledDamageables);
        }
        attackCoroutine = null;
        
    }
    private bool DisabledDamageables(IDamageable damageble)
    {
        return Damagebles != null && !damageble.GetTransform().gameObject.activeSelf;
    }
    
}

