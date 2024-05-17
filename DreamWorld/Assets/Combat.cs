using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Combat : MonoBehaviour
{
    private Animator animator;

    private int click;
    private bool clickActive;

 
    void Start()
    {
        animator = GetComponent<Animator>();
        click = 0;
        clickActive = true;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            Attack();
        }
    }

    void Attack()
    {
        if(clickActive)
        {
            click++;
        }

        if(click == 1)
        {
            animator.SetInteger("transition", 20);
        }
    }

    public void VerifyCombo()
    {
        clickActive = false;

        if(animator.GetCurrentAnimatorStateInfo(0).IsName("Melee Combo Attack") && click == 1)
        {
            animator.SetInteger("transition", 0);
            clickActive = true;
            click = 0;
        }else if(animator.GetCurrentAnimatorStateInfo(0).IsName("Melee Combo Attack") && click >= 2)
        {
            animator.SetInteger("transition", 21);
            clickActive = true;
        }else if(animator.GetCurrentAnimatorStateInfo(0).IsName("Melee Attack 360 High") && click == 2)
        {
            animator.SetInteger("transition", 0);
            clickActive = true;
            click = 0;
        }
    }
}
