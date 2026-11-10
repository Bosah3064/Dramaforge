import React, { useState, useEffect } from 'react';
import {
  ShieldAlert,
  Users,
  Coins,
  Activity,
  Search,
  AlertTriangle,
  CheckCircle,
  Ban,
  RefreshCw,
  Sliders,
} from 'lucide-react';
import { CoinBucket, EnforcementState } from 'dramaforge-shared';
import { adminApi } from './api';

export default function App() {
  const [activeTab, setActiveTab] = useState<'users' | 'moderation' | 'providers'>('users');
  const [users, setUsers] = useState<any[]>([]);
  const [modEvents, setModEvents] = useState<any[]>([]);
  const [providerHealth, setProviderHealth] = useState<any>(null);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(false);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);

  // Coin Adjustment Modal State
  const [selectedUser, setSelectedUser] = useState<any | null>(null);
  const [adjustBucket, setAdjustBucket] = useState<CoinBucket>(CoinBucket.PURCHASED);
  const [adjustAmount, setAdjustAmount] = useState<number>(50);
  const [adjustReason, setAdjustReason] = useState<string>('Customer support credit');

  useEffect(() => {
    loadData();
  }, [activeTab]);

  const loadData = async () => {
    setLoading(true);
    setStatusMessage(null);
    try {
      if (activeTab === 'users') {
        const data = await adminApi.getUsers(search);
        setUsers(data);
      } else if (activeTab === 'moderation') {
        const events = await adminApi.getModerationQueue();
        setModEvents(events);
      } else if (activeTab === 'providers') {
        const health = await adminApi.getProviderHealth();
        setProviderHealth(health);
      }
    } catch (err: any) {
      console.warn('API connection test:', err.message);
      // Demo mock fallback if token/backend not seeded yet
      if (activeTab === 'users') {
        setUsers([
          {
            id: 'demo-user-1',
            email: 'creator@dramaforge.ai',
            role: 'USER',
            enforcementState: 'NONE',
            isAgeVerified: true,
            createdAt: new Date().toISOString(),
            balance: { totalCoins: 350, subscriptionCoins: 200, purchasedCoins: 150 },
          },
          {
            id: 'demo-user-2',
            email: 'badactor@example.com',
            role: 'USER',
            enforcementState: 'WARNING',
            isAgeVerified: true,
            createdAt: new Date().toISOString(),
            balance: { totalCoins: 20, subscriptionCoins: 0, purchasedCoins: 20 },
          },
        ]);
      } else if (activeTab === 'moderation') {
        setModEvents([
          {
            id: 'mod-1',
            userId: 'demo-user-2',
            contentType: 'TEXT',
            triggerKeyword: 'revenge porn',
            riskScore: 1.0,
            actionTaken: 'BLOCK',
            createdAt: new Date().toISOString(),
            user: { email: 'badactor@example.com', enforcementState: 'WARNING' },
          },
        ]);
      } else if (activeTab === 'providers') {
        setProviderHealth({
          activeProvider: 'MOCK (Deterministic Dev)',
          status: 'HEALTHY',
          timestamp: new Date().toISOString(),
          capabilities: {
            textGeneration: true,
            imageKeyframes: true,
            videoSynthesis: true,
            photoEffects: true,
            assembly: true,
          },
        });
      }
    } finally {
      setLoading(false);
    }
  };

  const handleEnforce = async (userId: string, state: EnforcementState) => {
    try {
      await adminApi.enforceUser(userId, state, 'Admin dashboard action');
      setStatusMessage(`User enforcement state updated to ${state}`);
      loadData();
    } catch (err: any) {
      setStatusMessage(`Action note: ${err.message}`);
    }
  };

  const handleAdjustCoins = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedUser) return;
    try {
      await adminApi.adjustCoins(selectedUser.id, adjustBucket, adjustAmount, adjustReason);
      setStatusMessage(`Adjusted ${adjustAmount} coins for ${selectedUser.email}`);
      setSelectedUser(null);
      loadData();
    } catch (err: any) {
      setStatusMessage(`Adjustment note: ${err.message}`);
      setSelectedUser(null);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-slate-950 text-slate-100">
      {/* Header */}
      <header className="border-b border-slate-800 bg-slate-900/50 backdrop-blur px-6 py-4 flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-purple-600 to-indigo-500 flex items-center justify-center font-black text-xl shadow-lg shadow-purple-500/20">
            DF
          </div>
          <div>
            <h1 className="font-bold text-lg leading-tight tracking-wide text-white">DramaForge</h1>
            <p className="text-xs text-slate-400">Admin Operations & Moderation Studio</p>
          </div>
        </div>

        {/* Navigation Tabs */}
        <nav className="flex space-x-2 bg-slate-900 p-1 rounded-xl border border-slate-800">
          <button
            onClick={() => setActiveTab('users')}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg text-sm font-medium transition ${
              activeTab === 'users' ? 'bg-purple-600 text-white shadow' : 'text-slate-400 hover:text-white'
            }`}
          >
            <Users className="w-4 h-4" />
            <span>Users & Ledgers</span>
          </button>
          <button
            onClick={() => setActiveTab('moderation')}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg text-sm font-medium transition ${
              activeTab === 'moderation' ? 'bg-purple-600 text-white shadow' : 'text-slate-400 hover:text-white'
            }`}
          >
            <ShieldAlert className="w-4 h-4" />
            <span>Safety Queue</span>
          </button>
          <button
            onClick={() => setActiveTab('providers')}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg text-sm font-medium transition ${
              activeTab === 'providers' ? 'bg-purple-600 text-white shadow' : 'text-slate-400 hover:text-white'
            }`}
          >
            <Activity className="w-4 h-4" />
            <span>Provider Health</span>
          </button>
        </nav>
      </header>

      {/* Main Content */}
      <main className="flex-1 p-8 max-w-7xl w-full mx-auto">
        {statusMessage && (
          <div className="mb-6 p-4 rounded-xl bg-purple-950/40 border border-purple-500/40 text-purple-200 text-sm flex items-center justify-between">
            <span>{statusMessage}</span>
            <button onClick={() => setStatusMessage(null)} className="text-slate-400 hover:text-white">✕</button>
          </div>
        )}

        {/* Tab 1: Users */}
        {activeTab === 'users' && (
          <div>
            <div className="flex items-center justify-between mb-6">
              <div className="relative w-96">
                <Search className="w-4 h-4 absolute left-3 top-3 text-slate-500" />
                <input
                  type="text"
                  placeholder="Search user by email or ID..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && loadData()}
                  className="w-full pl-9 pr-4 py-2 bg-slate-900 border border-slate-800 rounded-xl text-sm focus:outline-none focus:border-purple-500"
                />
              </div>
              <button
                onClick={loadData}
                className="flex items-center space-x-2 px-4 py-2 bg-slate-900 hover:bg-slate-800 border border-slate-800 rounded-xl text-sm"
              >
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                <span>Refresh</span>
              </button>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
              <table className="w-full text-left text-sm text-slate-300">
                <thead className="bg-slate-800/60 text-xs uppercase text-slate-400 font-semibold border-b border-slate-800">
                  <tr>
                    <th className="px-6 py-4">User</th>
                    <th className="px-6 py-4">Dual-Bucket Balance</th>
                    <th className="px-6 py-4">Age 13+</th>
                    <th className="px-6 py-4">Enforcement Tier</th>
                    <th className="px-6 py-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800/60">
                  {users.map((u) => (
                    <tr key={u.id} className="hover:bg-slate-800/30 transition">
                      <td className="px-6 py-4">
                        <div className="font-semibold text-white">{u.email}</div>
                        <div className="text-xs text-slate-500 font-mono">{u.id}</div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center space-x-2 font-mono">
                          <Coins className="w-4 h-4 text-amber-400" />
                          <span className="font-bold text-white">{u.balance?.totalCoins ?? 0} total</span>
                        </div>
                        <div className="text-xs text-slate-400 mt-1">
                          <span className="text-indigo-400">{u.balance?.subscriptionCoins ?? 0} Sub</span> ·{' '}
                          <span className="text-emerald-400">{u.balance?.purchasedCoins ?? 0} Purchased</span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        {u.isAgeVerified ? (
                          <span className="px-2 py-1 bg-emerald-950 text-emerald-400 border border-emerald-800 text-xs rounded-full">
                            Verified 13+
                          </span>
                        ) : (
                          <span className="px-2 py-1 bg-rose-950 text-rose-400 border border-rose-800 text-xs rounded-full">
                            Pending
                          </span>
                        )}
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={`px-2.5 py-1 text-xs rounded-full font-medium border ${
                            u.enforcementState === 'NONE'
                              ? 'bg-slate-800 text-slate-300 border-slate-700'
                              : u.enforcementState === 'WARNING'
                              ? 'bg-amber-950 text-amber-300 border-amber-800'
                              : u.enforcementState === 'FEATURE_LIMIT'
                              ? 'bg-orange-950 text-orange-300 border-orange-800'
                              : 'bg-rose-950 text-rose-300 border-rose-800'
                          }`}
                        >
                          {u.enforcementState}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-right space-x-2">
                        <button
                          onClick={() => setSelectedUser(u)}
                          className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 border border-slate-700 rounded-lg text-xs font-medium text-slate-200 inline-flex items-center space-x-1"
                        >
                          <Sliders className="w-3.5 h-3.5" />
                          <span>Coins</span>
                        </button>
                        {u.enforcementState !== 'BANNED' ? (
                          <button
                            onClick={() => handleEnforce(u.id, EnforcementState.BANNED)}
                            className="px-3 py-1.5 bg-rose-950/60 hover:bg-rose-900 border border-rose-800 rounded-lg text-xs font-medium text-rose-300 inline-flex items-center space-x-1"
                          >
                            <Ban className="w-3.5 h-3.5" />
                            <span>Ban</span>
                          </button>
                        ) : (
                          <button
                            onClick={() => handleEnforce(u.id, EnforcementState.NONE)}
                            className="px-3 py-1.5 bg-emerald-950/60 hover:bg-emerald-900 border border-emerald-800 rounded-lg text-xs font-medium text-emerald-300 inline-flex items-center space-x-1"
                          >
                            <CheckCircle className="w-3.5 h-3.5" />
                            <span>Unban</span>
                          </button>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Tab 2: Moderation Queue */}
        {activeTab === 'moderation' && (
          <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
            <div className="p-6 border-b border-slate-800">
              <h2 className="text-base font-semibold text-white">Flagged Safety & Moderation Events</h2>
              <p className="text-xs text-slate-400 mt-1">Multi-stage regex, keyword, and deepfake prevention violations</p>
            </div>
            <table className="w-full text-left text-sm text-slate-300">
              <thead className="bg-slate-800/60 text-xs uppercase text-slate-400 font-semibold border-b border-slate-800">
                <tr>
                  <th className="px-6 py-4">Trigger Keyword</th>
                  <th className="px-6 py-4">Risk Score</th>
                  <th className="px-6 py-4">Action Taken</th>
                  <th className="px-6 py-4">User</th>
                  <th className="px-6 py-4">Timestamp</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/60">
                {modEvents.map((evt) => (
                  <tr key={evt.id} className="hover:bg-slate-800/30">
                    <td className="px-6 py-4 font-mono font-bold text-rose-400">{evt.triggerKeyword}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center space-x-2">
                        <div className="w-16 bg-slate-800 rounded-full h-2 overflow-hidden">
                          <div
                            className="bg-rose-500 h-2 rounded-full"
                            style={{ width: `${evt.riskScore * 100}%` }}
                          />
                        </div>
                        <span className="font-mono text-xs text-slate-400">{(evt.riskScore * 100).toFixed(0)}%</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-2.5 py-1 bg-rose-950 text-rose-300 border border-rose-800 rounded-full text-xs font-semibold">
                        {evt.actionTaken}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-white">{evt.user?.email || evt.userId}</span>
                    </td>
                    <td className="px-6 py-4 text-xs text-slate-500">{new Date(evt.createdAt).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Tab 3: Providers Health */}
        {activeTab === 'providers' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
              <h2 className="text-base font-semibold text-white mb-4">Active AI Gateway Status</h2>
              <div className="space-y-4">
                <div className="flex justify-between items-center py-2 border-b border-slate-800">
                  <span className="text-slate-400">Provider Mode</span>
                  <span className="font-mono font-semibold text-purple-400">{providerHealth?.activeProvider}</span>
                </div>
                <div className="flex justify-between items-center py-2 border-b border-slate-800">
                  <span className="text-slate-400">Status</span>
                  <span className="inline-flex items-center space-x-1.5 text-emerald-400 font-semibold text-xs bg-emerald-950 px-2.5 py-1 rounded-full border border-emerald-800">
                    <CheckCircle className="w-3.5 h-3.5" />
                    <span>{providerHealth?.status}</span>
                  </span>
                </div>
                <div className="flex justify-between items-center py-2">
                  <span className="text-slate-400">Last Health Check</span>
                  <span className="text-xs text-slate-500">{providerHealth?.timestamp}</span>
                </div>
              </div>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
              <h2 className="text-base font-semibold text-white mb-4">Pipeline Capabilities</h2>
              <ul className="space-y-2 text-sm">
                <li className="flex items-center space-x-2 text-slate-300">
                  <CheckCircle className="w-4 h-4 text-emerald-400" />
                  <span>3-Act LLM Script & Character Profile Generation</span>
                </li>
                <li className="flex items-center space-x-2 text-slate-300">
                  <CheckCircle className="w-4 h-4 text-emerald-400" />
                  <span>Keyframe Text-to-Image with Aspect Ratio Controls</span>
                </li>
                <li className="flex items-center space-x-2 text-slate-300">
                  <CheckCircle className="w-4 h-4 text-emerald-400" />
                  <span>Image-to-Video Multi-Shot Orchestration</span>
                </li>
                <li className="flex items-center space-x-2 text-slate-300">
                  <CheckCircle className="w-4 h-4 text-emerald-400" />
                  <span>Viral Photo Effects (Hug, Kiss, Dance, Aging)</span>
                </li>
                <li className="flex items-center space-x-2 text-slate-300">
                  <CheckCircle className="w-4 h-4 text-emerald-400" />
                  <span>Pre-Deduction & Compensating Auto-Refund Ledger</span>
                </li>
              </ul>
            </div>
          </div>
        )}

        {/* Modal: Adjust Coins */}
        {selectedUser && (
          <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4 z-50">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-md w-full p-6 shadow-2xl">
              <h3 className="text-lg font-bold text-white mb-1">Adjust Coin Balance</h3>
              <p className="text-xs text-slate-400 mb-4">User: {selectedUser.email}</p>

              <form onSubmit={handleAdjustCoins} className="space-y-4">
                <div>
                  <label className="block text-xs uppercase text-slate-400 font-semibold mb-1">Target Bucket</label>
                  <select
                    value={adjustBucket}
                    onChange={(e) => setAdjustBucket(e.target.value as CoinBucket)}
                    className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-slate-200"
                  >
                    <option value={CoinBucket.PURCHASED}>Purchased Coins (Non-expiring)</option>
                    <option value={CoinBucket.SUBSCRIPTION}>Subscription Coins (Cycle expiring)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs uppercase text-slate-400 font-semibold mb-1">Amount (+ grant / - deduct)</label>
                  <input
                    type="number"
                    value={adjustAmount}
                    onChange={(e) => setAdjustAmount(Number(e.target.value))}
                    className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-slate-200 font-mono"
                  />
                </div>

                <div>
                  <label className="block text-xs uppercase text-slate-400 font-semibold mb-1">Audit Reason (Mandatory)</label>
                  <input
                    type="text"
                    value={adjustReason}
                    onChange={(e) => setAdjustReason(e.target.value)}
                    required
                    className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-slate-200"
                  />
                </div>

                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => setSelectedUser(null)}
                    className="px-4 py-2 bg-slate-800 hover:bg-slate-700 rounded-xl text-sm font-medium"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-purple-600 hover:bg-purple-500 text-white rounded-xl text-sm font-semibold shadow-lg shadow-purple-600/30"
                  >
                    Confirm Adjustment
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

