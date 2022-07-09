namespace SuperLeague
{
    public class Match
    {
        public string homeTeam { get; }
        public string awayTeam { get; }
        public int homeGoals { get; }
        public int awayGoals { get; }

        public Match(string homeTeam, string awayTeam, int homeGoals, int awayGoals)
        {
            this.homeTeam = homeTeam;
            this.awayTeam = awayTeam;
            this.homeGoals = homeGoals;
            this.awayGoals = awayGoals;
        }

        public override string ToString()
        {
            return $"{this.homeTeam} {this.homeGoals}:{this.awayGoals} {this.awayTeam}";
        }
    }
}
