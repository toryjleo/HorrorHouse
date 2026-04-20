namespace AdventurePuzzleKit
{
    /// <summary>
    /// Any transient interaction that can be dismissed for pause implements IPauseClosable
    /// </summary>
    public interface IPauseClosable
    {
        void CloseForPause();
    }
}
