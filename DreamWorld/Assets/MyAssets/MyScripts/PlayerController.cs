
using UnityEngine;
using UnityEngine.UIElements;

public class PlayerController : MonoBehaviour
{

    bool left, right, forward,backward,jump;
    bool isGround;


    [SerializeField] public Rigidbody rb;
    [SerializeField] public float speed,maxSpeed,drag,jumpForce;
    [SerializeField] public float rotationSpeed;
    [SerializeField] public Transform transCam;

    [SerializeField] public LayerMask ground;
    // Update is called once per frame
    void Update()
    {
        HandleInput();
        LimitVelocity();
        HandleDrag();
        IsGrounded();
    }


    private void FixedUpdate()
    {
        HandleMovement();
        HandleRotation();
    }


    void LimitVelocity()
    {
        Vector3 horVelocity = new Vector3(rb.velocity.x,0,rb.velocity.z);
        if (horVelocity.magnitude > maxSpeed)
        {
            Vector3 limitedVelocity = horVelocity.normalized * maxSpeed;
            rb.velocity = new Vector3(speed*limitedVelocity.x,rb.velocity.y,limitedVelocity.z);
        }
    }


    void HandleRotation()
    {
        if((new Vector2(rb.velocity.x,rb.velocity.z)).magnitude > 0.1f)
            {
            Vector3 horDir = new Vector3(rb.velocity.x, 0, 0);
            Quaternion rotation = Quaternion.LookRotation(horDir, Vector3.up);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation,rotationSpeed);
        }
    }


    void HandleDrag()
    {
        rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.z) / (1 + drag / 100) + new Vector3(0, rb.velocity.y, 0);
    }
    void HandleMovement()
    {
        Quaternion dir = Quaternion.Euler(0f, transCam.rotation.eulerAngles.y, 0f);
        if (left)
        {
            rb.AddForce(dir * Vector3.left * speed);
            left = false;
        }
        if (right)
        {
            rb.AddForce(dir * Vector3.right * speed);
            right = false;
        }
        if (forward)
        {
            rb.AddForce(dir * Vector3.forward * speed);
            forward = false;
        }
        if (backward)
        {
            rb.AddForce(dir * Vector3.back * speed);
            backward = false;
        }
        if (jump && isGround)
        {
            transform.position += Vector3.up * 0.1f;
            rb.velocity = new Vector3(rb.velocity.x,0,rb.velocity.z);
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            jump = false;
        }
    }
    void HandleInput()
    {
        
        if (Input.GetKey(KeyCode.W))
        {
            forward = true;
        }
        if (Input.GetKey(KeyCode.A))
        {
            left = true;
        }
        if (Input.GetKey(KeyCode.S))
        {
            backward = true;
        }
        if (Input.GetKey(KeyCode.D))
        {
            right = true;
        }
        if (Input.GetKeyDown(KeyCode.Space)&& isGround)
        {
            jump = true;
        }
    }
    void IsGrounded()
    {
        isGround = Physics.Raycast(transform.position + Vector3.up * 0.1f, Vector3.down, 0.2f, ground);
    }
}
