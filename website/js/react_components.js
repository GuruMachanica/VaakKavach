/**
 * VaakKavach - React 18 Dynamic Threat Lab Component
 */
(function () {
  if (typeof React === 'undefined' || typeof ReactDOM === 'undefined') return;

  const { useState, useEffect } = React;

  const SCENARIOS = [
    { id: 'safe', name: 'Genuine Caller', desc: 'Natural vocal tract jitter, continuous harmonic resonance', score: '0.02%', threat: false, phase: '0.012 rad', cutoff: '24.2 kHz', action: 'PASS_THROUGH' },
    { id: 'clone', name: 'ElevenLabs Voice Clone', desc: 'Stolen timbre clone: "Emergency wire transfer request"', score: '98.4%', threat: true, phase: '1.480 rad', cutoff: '16.0 kHz', action: 'HAPTIC_WARN' },
    { id: 'inject', name: 'Virtual Audio Injection', desc: 'Robotic spectral cutoff with phase nullification', score: '99.1%', threat: true, phase: '2.140 rad', cutoff: '12.0 kHz', action: 'QUARANTINE_MUTED' },
    { id: 'bank', name: 'Neural Banking Extortion', desc: 'TTS Neural speech synthesis attempting OTP extraction', score: '94.7%', threat: true, phase: '0.985 rad', cutoff: '18.4 kHz', action: 'EMERGENCY_SMS' }
  ];

  function ThreatLabApp() {
    const [selected, setSelected] = useState(SCENARIOS[0]);
    const [isPlaying, setIsPlaying] = useState(false);
    const [quarantined, setQuarantined] = useState(false);

    const handleSelect = (scenario) => {
      setSelected(scenario);
      setQuarantined(false);
      const isThreat = scenario.threat;

      if (window.synth) window.synth.setMode(isThreat ? 'threat' : 'safe');
      if (window.threeScene) window.threeScene.setThreatMode(isThreat);
      if (window.pixiSpectrogram) window.pixiSpectrogram.setThreatMode(isThreat);
      if (window.VaakAnimeEffects && isThreat) {
        window.VaakAnimeEffects.triggerThreatGlitch('#react-threat-lab-root');
      }
    };

    const toggleAudio = () => {
      if (!window.synth) return;
      window.synth.toggle((playing) => setIsPlaying(playing));
    };

    const quarantineCall = () => {
      setQuarantined(true);
      if (window.synth) window.synth.stop();
      setIsPlaying(false);
      alert('🔒 [VaakKavach Level-0]: Call Audio Muted & Audio Signature Hashed to SQLite Ledger.');
    };

    return React.createElement('div', { className: 'threat-lab-console' },
      React.createElement('div', { className: 'console-sidebar' },
        React.createElement('h3', { className: 'sidebar-heading' }, 'SELECT ATTACK SCENARIO'),
        React.createElement('div', { className: 'scenario-list' },
          SCENARIOS.map(s =>
            React.createElement('button', {
              key: s.id,
              type: 'button',
              className: `scenario-card ${selected.id === s.id ? 'active' : ''}`,
              onClick: () => handleSelect(s)
            },
              React.createElement('div', { className: `scenario-status-indicator ${s.threat ? 'indicator-crimson' : 'indicator-emerald'}` }),
              React.createElement('div', { className: 'scenario-info' },
                React.createElement('div', { className: 'scenario-name' }, s.name),
                React.createElement('div', { className: 'scenario-desc' }, s.desc)
              ),
              React.createElement('span', { className: `scenario-badge ${s.threat ? 'threat' : 'safe'}` }, s.threat ? 'THREAT' : 'SAFE')
            )
          )
        )
      ),
      React.createElement('div', { className: 'console-main' },
        React.createElement('div', { className: `telemetry-banner ${selected.threat ? 'threat-active' : ''}` },
          React.createElement('div', null,
            React.createElement('span', { className: 'banner-status-tag' }, selected.threat ? 'ALERT: ADVERSARIAL ANOMALY DETECTED' : 'SYSTEM STATUS: HARMONIC SAFE'),
            React.createElement('h4', { className: 'banner-title' }, selected.name)
          ),
          React.createElement('div', { className: 'banner-score-box' },
            React.createElement('span', { className: 'score-label' }, 'ANOMALY SCORE'),
            React.createElement('span', { className: `score-value font-mono ${selected.threat ? 'text-crimson' : 'text-emerald'}` }, selected.score)
          )
        ),
        React.createElement('div', { className: 'threat-actions-bar' },
          React.createElement('button', { type: 'button', className: 'btn btn-audio-play', onClick: toggleAudio },
            isPlaying ? 'Stop Audio Buffer' : 'Simulate Call Audio'
          ),
          React.createElement('button', {
            type: 'button',
            className: 'btn btn-neutralize',
            disabled: !selected.threat || quarantined,
            onClick: quarantineCall
          }, quarantined ? 'CALL QUARANTINED' : (selected.threat ? 'MUTE / QUARANTINE CALL' : 'NORMAL STREAM (NO THREAT)'))
        ),
        React.createElement('div', { className: 'forensics-grid' },
          React.createElement('div', { className: 'forensic-cell' },
            React.createElement('span', { className: 'metric-name' }, 'Phase Jitter'),
            React.createElement('span', { className: 'metric-val font-mono' }, selected.phase),
            React.createElement('div', { className: 'metric-bar-bg' },
              React.createElement('div', { className: `metric-bar-fill ${selected.threat ? 'fill-crimson' : 'fill-emerald'}`, style: { width: selected.threat ? '88%' : '8%' } })
            )
          ),
          React.createElement('div', { className: 'forensic-cell' },
            React.createElement('span', { className: 'metric-name' }, 'Spectral Cutoff'),
            React.createElement('span', { className: 'metric-val font-mono' }, selected.cutoff),
            React.createElement('div', { className: 'metric-bar-bg' },
              React.createElement('div', { className: `metric-bar-fill ${selected.threat ? 'fill-crimson' : 'fill-emerald'}`, style: { width: selected.threat ? '92%' : '6%' } })
            )
          ),
          React.createElement('div', { className: 'forensic-cell' },
            React.createElement('span', { className: 'metric-name' }, 'Local Action'),
            React.createElement('span', { className: `metric-val font-mono ${selected.threat ? 'text-crimson' : 'text-emerald'}` }, selected.action),
            React.createElement('div', { className: 'metric-bar-bg' },
              React.createElement('div', { className: `metric-bar-fill ${selected.threat ? 'fill-crimson' : 'fill-emerald'}`, style: { width: '100%' } })
            )
          )
        )
      )
    );
  }

  window.initReactThreatLab = function (containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;
    const root = ReactDOM.createRoot(container);
    root.render(React.createElement(ThreatLabApp));
  };
})();
