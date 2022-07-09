using System;
using Xunit;

namespace SuperLeague.Tests
{
    public class MatchTest
    {
        [Fact]
        public void TestToString()
        {
            // Arrange
            var homeTeam = "Hansa Rostock";
            var awayTeam = "Fortuna Düsseldorf";
            var homeGoals = 2;
            var awayGoals = 3;
            Match match = new Match(homeTeam, awayTeam, homeGoals, awayGoals);

            // Act
            var actual = match.ToString();

            // Assert
            Assert.Equal("Hansa Rostock 2:3 Fortuna Düsseldorf", actual);
        }
    }
}
