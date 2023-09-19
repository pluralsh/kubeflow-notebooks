const name = process.env.APP_NAME;

module.exports = {
  branches: ["main"],
  tagFormat: name + '-v${version}',
  plugins: [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/github",
    [
      "@semantic-release/exec",
      {
        "verifyReleaseCmd": "echo ${nextRelease.version} > release_version"
      }
    ]
  ],
  commitPaths: [
    name,
  ]
};
