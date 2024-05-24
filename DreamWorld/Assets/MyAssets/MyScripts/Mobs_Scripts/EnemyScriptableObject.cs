using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


[CreateAssetMenu(fileName = "Configurações de Inimigo", menuName = "Scriptable/Configurações de Inimigos")]
public class EnemyScriptableObject : MonoBehaviour
{
    //Stats
    public int Health = 100;
    public float AttackDelay = 1.5f;
    public int Damage = 7;
    public float attackRadius = 1.7f;


    // NavMesh
    public float aiUpdateInterval = 0.1f;

    public float Acceleration = 8;
    public float AngularSpeed = 120;
}
