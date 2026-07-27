using UnityEngine;

public class JumpScareTestTrigger : MonoBehaviour
{
    [SerializeField] private JumpscareData jumpscare;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            JumpscarePlayer.Play(jumpscare);
        }
    }
}
