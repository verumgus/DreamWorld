using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.AI;

public class State 
{

    public enum STATE
    {
        IDLE,WALK,RUN

    }

    public enum EVENT
    {
        ENTER, UPDATE,EXIT
    }

    public STATE stateName;
    protected EVENT stage;
    protected GameObject npc;
    protected NavMeshAgent agent;
    protected Animator anim;
    protected Transform player;
    protected Transform[] waypoints;
    protected State nextState;

    public State(GameObject _npc,NavMeshAgent _agent,Animator _anim, Transform _player, Transform[] _waypoint)
    {
        npc = _npc;
        agent = _agent;
        anim = _anim;
        player = _player;
        waypoints = _waypoint;

    }

    public virtual void Enter()
    {
        stage = EVENT.UPDATE;
    }

    public virtual void Update()
    {
        stage = EVENT.UPDATE;
    }
    public virtual void Exit()
    {
        stage = EVENT.EXIT;
    }

    public  State Process()
    {
        if(stage == EVENT.ENTER)
        {
            Enter();    
        }
        else if(stage == EVENT.UPDATE)
        {
            Update();

        }
        else
        {
            Exit();
            return nextState;
        }
        return this;
    }

    public class Idle : State
    {
        float timer;
        public Idle(GameObject _npc, NavMeshAgent _agent, Animator _anim, Transform _player, Transform[] _waypoint) : base(_npc, _agent, _anim, _player, _waypoint)
        {
            stateName = STATE.IDLE;
        }

        public override void Enter()
        {
            agent.isStopped = true;
            anim.SetTrigger("idle");
            Debug.Log("Entro em idle");
            base.Enter();
        }

        public override void Update()
        {
            Debug.Log("Rodando o Idle");
            timer += Time.deltaTime;
            if (timer > 3)
            {
                stage = EVENT.EXIT;
            }
        }

        public override void Exit()
        {
            anim.ResetTrigger("idle");
            base.Exit();
        }
    }

}
