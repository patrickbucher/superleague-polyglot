package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"

	"code.frickelbude.ch/m426/superleague-go"
)

func main() {
	if len(os.Args) < 2 {
		log.Fatalf("usage: %s [matches.json]\n", os.Args[0])
	}
	matches, err := readMatches(os.Args[1])
	if err != nil {
		log.Fatalf("reading matches: %v", err)
	}
	table, err := superleague.CreateTable(matches)
	if err != nil {
		log.Fatalf("creating table: %v", err)
	}
	fmt.Print(table)
}

func readMatches(jsonFilePath string) ([]superleague.Match, error) {
	matchesFile, err := os.Open(jsonFilePath)
	if err != nil {
		return nil, fmt.Errorf("open file %s: %v", jsonFilePath, err)
	}
	defer matchesFile.Close()
	matchesData, err := io.ReadAll(matchesFile)
	if err != nil {
		return nil, fmt.Errorf("reading file %s: %v", jsonFilePath, err)
	}
	matches := make([]superleague.Match, 0)
	if err = json.Unmarshal(matchesData, &matches); err != nil {
		return nil, fmt.Errorf("unmarshal json: %v", err)
	}
	return matches, nil
}
