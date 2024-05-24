using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Combat : MonoBehaviour
{
    private Animator animator;
    public float coldownTime = 2f;
    private float nextFireTime = 0f;
    public static int noOfClicks = 0;
    float lastClickTime = 0;
    float maxComboDelay = 1;


 
    void Start()
    {
     animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7 && animator.GetCurrentAnimatorStateInfo(0).IsName("attack_1"))
        {
            animator.SetBool("hit_1", false);
        }
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7 && animator.GetCurrentAnimatorStateInfo(0).IsName("attack_2"))
        {
            animator.SetBool("hit_2", false);
        }
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7 && animator.GetCurrentAnimatorStateInfo(0).IsName("attack_3"))
        {
            animator.SetBool("hit_3", false);
            noOfClicks = 0;
        }

        if(Time.time - lastClickTime> maxComboDelay)
        {
            noOfClicks = 0;
        }
        if(Time.time> nextFireTime)
        {
            if(Input.GetMouseButtonDown(0))
            {
                Onclick();
            }
        }
    }

    void Onclick()
    {
        lastClickTime = Time.time;
        noOfClicks++;
        if(noOfClicks == 1)
        {
            animator.SetBool("hit_1", true);

        }
        noOfClicks = Mathf.Clamp(noOfClicks, 0, 3);

        if(noOfClicks>=2 && animator.GetCurrentAnimatorStateInfo(0).normalizedTime>0.7&& animator.GetCurrentAnimatorStateInfo(0).IsName("attack_1"))
        {
            animator.SetBool("hit_1", false);
            animator.SetBool("hit_2", true);
            
        }

        if (noOfClicks >= 3 && animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7 && animator.GetCurrentAnimatorStateInfo(0).IsName("attack_2"))
        {
            animator.SetBool("hit_2", false);
            animator.SetBool("hit_3", true);
            
        }

    }
 
}
