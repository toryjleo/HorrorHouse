namespace AdventurePuzzleKit
{
    /// <summary>
    /// Items register themselves with PauseCloseRegistry
    /// </summary>
    public static class PauseCloseRegistry
    {
        public static IPauseClosable Current { get; private set; }

        /// <summary>
        /// Item opens
        /// </summary>
        /// <param name="pauseClosable"></param>
        public static void Register(IPauseClosable pauseClosable)
        {
            Current = pauseClosable;
        }

        /// <summary>
        /// Item closes
        /// </summary>
        /// <param name="pauseClosable"></param>
        public static void Unregister(IPauseClosable pauseClosable)
        {
            if (!ReferenceEquals(Current, pauseClosable)) return;
            Current = null;
        }

        public static void CloseCurrent()
        {
            Current?.CloseForPause();
        }
    }
}
