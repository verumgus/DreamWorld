using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Combat : MonoBehaviour
{
    Animator animator;

    int countClick;
    bool canClick;

     void Start()
    {
        animator = GetComponent<Animator>();
        countClick = 0;
        canClick = true;
    }

     void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            StartCombo();
        }

    }

    private void StartCombo()
    {
        if (canClick)
        {
            countClick++;
        }

        if (countClick == 1)
        {
            animator.SetInteger("attack", 1);
        }
    }

    private void InCombo()
    {
        canClick = false;

        if(animator.GetCurrentAnimatorStateInfo(0).IsName("hit_1") &&  countClick == 1)
        {
            animator.SetInteger("attack", 0);
            canClick = true;    
            countClick = 0;
        }
        else if(animator.GetCurrentAnimatorStateInfo(0).IsName("hit_1") && countClick >= 2)
        {
            animator.SetInteger("attack", 2);
            canClick = true;
            
        }
        else if(animator.GetCurrentAnimatorStateInfo(0).IsName("hit_2") && countClick == 2)
        {
            animator.SetInteger("attack", 0);
            canClick = true;
            countClick = 0;
        }
        else if(animator.GetCurrentAnimatorStateInfo(0).IsName("hit_2") && countClick >= 3)
        {
            animator.SetInteger("attack", 3);
            canClick = true;
        }
        else if (animator.GetCurrentAnimatorStateInfo(0).IsName("hit3"))
        {
            animator.SetInteger("attack", 0);
            canClick = true;
            countClick = 0;
        }
    }

}
