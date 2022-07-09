using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;

namespace SuperLeague
{
    class Table
    {
        static void Main(string[] args)
        {
            foreach (Match match in ReadMatches(args[0]))
            {
                Console.WriteLine(match.ToString());
            }
        }

        public static List<Match> ReadMatches(string jsonPath) 
        {
            using (StreamReader r = new StreamReader(jsonPath))
            {
                string json = r.ReadToEnd();
                List<Match> matches = JsonConvert.DeserializeObject<List<Match>>(json);
                return matches;
            }
        }
    }
}
