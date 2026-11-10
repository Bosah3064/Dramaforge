import { CoinBucket, EnforcementState } from 'dramaforge-shared';

const API_BASE = '/api/v1';

export async function fetchWithAuth(endpoint: string, options: RequestInit = {}) {
  const token = localStorage.getItem('dramaforge_admin_token') || '';
  const headers = {
    'Content-Type': 'application/json',
    Authorization: token ? `Bearer ${token}` : '',
    ...(options.headers || {}),
  };

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: response.statusText }));
    throw new Error(error.message || 'API request failed');
  }

  return response.json();
}

export const adminApi = {
  getUsers: (search = '') => fetchWithAuth(`/admin/users${search ? `?search=${encodeURIComponent(search)}` : ''}`),
  enforceUser: (id: string, state: EnforcementState, reason: string) =>
    fetchWithAuth(`/admin/users/${id}/enforce`, {
      method: 'POST',
      body: JSON.stringify({ state, reason }),
    }),
  adjustCoins: (id: string, bucket: CoinBucket, amount: number, reason: string) =>
    fetchWithAuth(`/admin/users/${id}/adjust-coins`, {
      method: 'POST',
      body: JSON.stringify({ bucket, amount, reason }),
    }),
  getModerationQueue: () => fetchWithAuth('/admin/moderation/queue'),
  getProviderHealth: () => fetchWithAuth('/admin/providers/health'),
};

