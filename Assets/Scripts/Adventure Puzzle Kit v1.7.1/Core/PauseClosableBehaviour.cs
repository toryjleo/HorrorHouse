using UnityEngine;

namespace AdventurePuzzleKit
{
    public abstract class PauseClosableBehaviour : MonoBehaviour, IPauseClosable
    {
        protected void RegisterPauseClose()
        {
            PauseCloseRegistry.Register(this);
        }

        protected void UnregisterPauseClose()
        {
            PauseCloseRegistry.Unregister(this);
        }

        protected virtual void OnDisable()
        {
            UnregisterPauseClose();
        }

        public abstract void CloseForPause();
    }
}
